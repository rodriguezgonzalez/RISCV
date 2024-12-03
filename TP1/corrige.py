#!/usr/bin/env python3

# Script de correction pour TP INF2171

import sys
import os
import subprocess
import re
from pathlib import Path

class Correction:
    def __init__(self, path):
        self.path = path  # Fichier source
        self.tests = []  # Liste de tests
        self.etudiants = []  # Liste de code permanents

    def check(self, res, desc):
        "Enregistre le résultat d'un test"
        test = Test(desc)
        test.res = res
        self.tests.append(test)
        return test

    def check_source(self):
        res = os.path.exists(self.path)
        test = self.check(res, "Source")
        test.details = self.path
        test.show()
        return res

    def check_codepermanent(self):
        with open(self.path, errors='replace') as f:
            source = f.read()
        matches = re.findall(r'\b[A-Z]{4}[0-9]{8}\b', source)
        self.etudiants = matches
        res = len(matches) > 0
        test = self.check(res, "Codes permanent")
        if res:
            test.details = "Trouvé: " + ' '.join(matches)
        else:
            test.details = "Pas de code permanent trouvé. Format attendu: ABCD12345678"
        test.show()
        return res

    def check_assemble(self):
        cmd = ["java", "-jar", "rars.jar",
               "rv64", "nc", "me", "a", "ae1", self.path, "libs.s"]
        run = subprocess.run(cmd, input="", capture_output=True,
                             text=True, errors='replace', check=False)
        res = run.returncode == 0
        test = self.check(res, "Assemblage")
        if not res:
            test.details = run.stderr
        test.show()
        return res

    def run(self, stdin, prog=None):
        cmd = ["java", "-jar", "rars.jar",
               "rv64", "nc", "me", "se127", "10000000"]
        if prog:
            cmd.append(prog)
        cmd += [ self.path, "libs.s"]
        return subprocess.run(cmd, input=stdin, capture_output=True,
                              text=True, errors='replace', check=False)


    def check_case_dir(self, path):
        for f in sorted(list(Path(path).glob('*.s'))):
            src = f.read_text()
            m = re.search('#stdout:(.*)', src)
            stdout=m[1].encode('raw_unicode_escape').decode('unicode_escape')
            stdin=""
            self.check_case(stdin, stdout, prog=str(f), name=f.stem)
        for f in sorted(list(Path(path).glob('*.in'))):
            stdin = f.read_text().strip()
            stdout = f.with_suffix(".out").read_text().strip()
            self.check_case(stdin, stdout, name=f.stem)

    def check_case(self, stdin, output, prog=None, name=None):
        run = self.run(stdin + "\n", prog)
        stdout = run.stdout.strip()
        output = str(output)
        res = stdout == output
        test = self.check(res, name or stdin)

        if not res:
            if "Program terminated when maximum step limit" in run.stderr:
                test.details = "Temps d'exécution excessif. Exécution avortée. Peut-être un problème de boucle infinie?"
            elif len(stdout) == 0:
                test.details = f"La sortie du programme est vide. Attendu «{output}»"
            else:
                test.details = f"Obtenu «{stdout}». Attendu «{output}»"
                #escape = repr(stdout)[1:-1]
                #if escape != stdout:
                #    test.details += f"\nIl y a des octets douteux: «{escape}»"
        test.show()
        return test

    def check_all(self):
        if not self.check_source():
            return
        self.check_codepermanent()
        if not self.check_assemble():
            return
        print("TESTS PUBLICS :")
        self.check_case_dir("tests")
        print("TESTS PRIVÉS :")
        self.check_case_dir("priv-tests")

res_icons = {
    None: "????",
    True: "PASS",
    False: "FAIL"
}

def read_file(f):
    with open(f, 'r') as x:
        return f.read()

class Test:
    "Un simple test individuel"

    def __init__(self, desc):
        self.desc = desc  # Description du test
        self.res = None  # Résultat du test
        self.details = None

    def show(self):
        print(res_icons[self.res], " ", self.desc)
        if self.details is not None:
            for line in self.details.splitlines():
                if "RARS does not recognize the .weak directive." in line:
                    continue
                print("  ", line)


def main():
    if len(sys.argv) < 2:
        paths = ["poule.s"]
    else:
        paths = sys.argv[1:]
    for path in paths:
        correction = Correction(path)
        print(path)
        correction.check_all()


if __name__ == "__main__":
    main()
