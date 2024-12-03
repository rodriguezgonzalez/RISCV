#!/usr/bin/env python3

# Script de correction pour TP3 INF2171

import sys
import os
import subprocess
import re
import argparse
from pathlib import Path
import multiprocessing
from functools import partial
import uuid

def read_text2(pf):
    return pf.read_bytes()

class TestRunInfo:
    "Information sur un test à être executé"

    def __init__(self, stdin, expected, desc, type, prog=None, public=True):
        self.stdin = stdin
        self.expected = expected
        self.desc = desc
        self.type = type # Type (TEST, EXTRATEST)
        self.public = public # Est-ce que le test était publique
        self.prog = prog

    def create_testinfos():
        paths = ['tests', 'priv-tests'] # Test publique et privées
        testinfos = []
        for path in paths:
            for f in sorted(list(Path(path).glob('*.s'))):
                src = read_text2(f)
                m = re.search(b'#stdout:(.*)', src)
                expected = m[1].decode('unicode_escape').encode('utf-8')
                stdin=b""
                testinfos.append(TestRunInfo(stdin, expected, f.stem, 'TEST', prog=str(f)))
            for f in sorted(list(Path(path).glob('*.in'))):
                stdin = read_text2(f).strip()
                f_out = f.with_suffix(".out")
                expected = read_text2(f_out).strip()
                # Est-ce un test extra ?
                filename, _ = os.path.splitext(os.path.basename(f))
                type = 'EXTRATEST' if TestRunInfo.extract_number(filename) >= 90 else 'TEST'
                testinfos.append(TestRunInfo(stdin, expected, f.stem, type, public=path=='tests'))
        return testinfos

    def extract_number(s):
        # Regular expression to match a number surrounded by letters
        pattern = r'[a-zA-Z_]*([0-9]+)[a-zA-Z_]*'

        # Search for the pattern in the string
        match = re.search(pattern, s)

        # If a match is found, extract the number
        if match:
            return int(match.group(1))
        else:
            return None  # Return None if no number is found

class Correction:

    def __init__(self, path, filename, testinfos, verbose):
        self.path = path # Chemin vers le fichier
        self.filename = filename # Nom du fichier source demandé
        self.testResults = []  # Liste de résultat de tests
        self.etudiants = []  # Liste de code permanents
        self.testinfos = testinfos
        self.verbose = verbose

    def check(self, res, desc, type):
        "Enregistre le résultat d'un test"
        test = TestResult(desc, type)
        test.res = res
        self.testResults.append(test)
        return test

    def show(self, test):
        if self.verbose:
            test.show()
        return test

    def check_source(self):
        res = os.path.exists(self.path)
        test = self.check(res, "Source", type='FILE')
        test.details = self.path
        self.show(test)
        return res
    
    def check_filename(self):
        res = os.path.basename(self.path) == self.filename
        test = self.check(res, "Nom de fichier", type='SOURCE')
        if res:
            test.details = os.path.basename(self.path)
        else: 
            test.details = os.path.basename(self.path) +" n'est pas le fichier demandé."
        self.show(test)
        return res

    def check_codepermanent(self):
        with open(self.path, errors='replace') as f:
            source = f.read()
        matches = re.findall(r'\b[A-Z]{4}[0-9]{8}\b', source)
        self.etudiants = matches
        res = len(matches) > 0
        test = self.check(res, "Codes permanent", type='SOURCE')
        if res:
            test.details = "Trouvé: " + ' '.join(matches)
        else:
            test.details = "Pas de code permanent trouvé. Format attendu: ABCD12345678"
        self.show(test)
        return res

    def check_assemble(self):
        cmd = ["java", "-jar", "rars.jar",
               "rv64", "nc", "me", "a", "ae1", self.path, "libs.s"]
        run = subprocess.run(cmd, input="", capture_output=True,
                             text=True, errors='replace', check=False)
        res = run.returncode == 0
        test = self.check(res, "Assemblage", type='ASSEMBLE')
        if not res:
            test.details = run.stderr
        self.show(test)
        return res

    def run(self, stdin, prog=None):
        cmd = ["java", "-jar", "rars.jar",
               "rv64", "nc", "me", "se127", "100000000"]
        if prog:
            cmd.append(prog)
        cmd += [ self.path, "libs.s"]
        return subprocess.run(cmd, input=stdin, capture_output=True,
                              text=False, check=False)

    def check_testinfo(self, testinfo):
        run = self.run(testinfo.stdin + b"\n", testinfo.prog)
        stdout = run.stdout.strip()
        expected = testinfo.expected
        res = stdout == expected
        test = self.check(res, testinfo.desc or testinfo.stdin, type=testinfo.type)
        if not res:
            if b"Program terminated when maximum step limit" in run.stderr:
                test.details = "Temps d'exécution excessif. Exécution avortée. Peut-être un problème de boucle infinie?"
            elif len(stdout) == 0:
                test.details = f"La sortie du programme est vide. Attendu «{expected.decode(errors='replace')}»"
            else:
                escape = False
                for x in range(32):
                   if x == 10: # ASCII de \n
                      continue
                   if x in stdout:
                      escape = True
                      break
                if escape:
                   test.details = f"Il y a des octets douteux non affichables. Attendu la chaine «{expected.decode(errors='replace')}». Reçu «{repr(stdout)[2:-1]}», soit les octects : {' '.join([hex(i) for i in stdout])}"
                else:
                    test.details = f"Obtenu «{stdout.decode(errors='replace')}». Attendu «{expected.decode(errors='replace')}»"
        self.show(test)
        return test

    def check_all(self):
        if not self.check_source():
            return self
        self.check_filename()
        self.check_codepermanent()
        assemble_res = self.check_assemble()
        if not assemble_res:
            return self
        for testinfo in self.testinfos:
            self.check_testinfo(testinfo)
        
        return self
    
    def show_all(self):
        for test in self.testResults:
            test.show()
    
    def write_correction(self,path, corrections_path):
        """
        Écrit un fichier avec les code permanent dans
        le dossier corrections avec en en-tête les tests
        n'ayant pas passé et le score d'exécution
        """

        lines = ['#### TESTAUTOHEAD ####']
        lines.extend( [ '# ' + test.type + '! # ' + 
                        test.desc + ' ' + test.details 
                        for test in self.testResults if not test.res ] )
        if len(lines) == 1: # Tout passe
            lines.append('# Tous les tests fonctionnels sont bons.')
        if self.etudiants:
            filename_correction = '_'.join(self.etudiants) + ".s"
        else:
            # Tente de récupéré du dossier de Moodle
            name = path.split('/')[1].split('_')[0]
            if name:
                filename_correction = "MAUVAISCP_" + path.split('/')[1].split('_')[0] + ".s"
            else:
                filename_correction = "INCONNU" + str(uuid.uuid4()) + ".s"
        lines.append('#### TESTAUTOHEADEND ####')
        
        with open(path, 'r', errors='replace') as file_orig:
            contents = file_orig.read()

            with open(corrections_path + filename_correction, 'w') as file_write:
                for line in lines:
                    file_write.write(line.replace('\n', '\\n') + '\n')
                file_write.write('\n')
                file_write.write(contents)
        return filename_correction

                



def read_file(f):
    with open(f, 'r') as x:
        return f.read()

class TestResult:
    "Le résultat d'un test individuel"

    res_icons = {
        None: "????",
        True: "PASS",
        False: "FAIL"
    }

    def __init__(self, desc, type):
        self.desc = desc  # Description du test
        self.res = None  # Résultat du test
        self.details = None
        self.type = type

    def show(self):
        print(TestResult.res_icons[self.res], " ", self.desc, flush=True)
        if self.details is not None:
            for line in self.details.splitlines():
                if "RARS does not recognize the .weak directive." in line:
                    continue
                print("  ", line)
            

def correction_un_fichier(path, filename, testinfos, path_correction=None, verbose=False):
    correction = Correction(path, filename, testinfos, verbose)
    print("Correction de " + path + " en cours")
    correction = correction.check_all()
    if path_correction:
        return correction.write_correction(path,path_correction)
    return correction
    
def find_duplicates(filenames):
    # Count occurrences of each filename
    filename_count = {}
    for filename in filenames:
        filename_count[filename] = filename_count.get(filename, 0) + 1
    
    # Filter filenames with more than one occurrence
    duplicates = [filename for filename, count in filename_count.items() if count > 1]
    
    return duplicates

def main():
    filename = "morse.s"
    parser = argparse.ArgumentParser(description='Correcteur automatique pour INF2171')
    parser.add_argument('-c', '--correcteur', action='store_true', help='Active le mode pour correcteur')
    parser.add_argument('paths', nargs='*', default=[filename], help="Noms des fichiers à corriger, le fichier dans le dossier courant est utilisé par défault")
    args = parser.parse_args()

    testinfos = TestRunInfo.create_testinfos()

    if args.paths == 0:
        paths = [filename]
    else:
        paths = args.paths

    if args.correcteur:
        path_correction = 'corrections/'
        if not os.path.exists(path_correction):
            os.makedirs(path_correction)
        elif os.listdir(path_correction): # Pas touche à des fichiers existant
            print('Le dossier de corrections doit être vide')
            exit()

        partial_function = partial(correction_un_fichier, filename=filename, path_correction=path_correction, testinfos=testinfos)
        with multiprocessing.Pool() as pool:
            filenames_correction = pool.map(partial_function, paths)
    
        duplicate_files = find_duplicates(filenames_correction)
        print("Duplication count", len(duplicate_files))
        print("Duplicate filenames:", duplicate_files)
    else:
        for f in paths:
            correction_un_fichier(f, filename, testinfos, verbose=True)
            
if __name__ == "__main__":
    main()
