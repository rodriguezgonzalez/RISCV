# TP3 - Programme assembleur RISC-V , une bibliothèque de décodage Morse
# qui convertit un texte en code morse des un texte en clair.
# Rafael Rodriguez-Gonzalez RODR14019509 
# Groupe 010
########################################################################## 

.global miniMorse
.global decMorse
.global printMorse
.global newMorse
.global addMorse
.global printMorseLong  	# Partie ultra
	.data
	    			# Appels système RARS utilisés
	.eqv Sbrk, 9		# Sbrk n'est pas disponible dans libs.s
	.eqv Exit, 10
	.eqv PrintString, 4
	.eqv PrintChar, 11

	# Structure d'un noeud morse
	.eqv mCar, 0		# champ `caractere` (dword)
	.eqv mPoint, 8		# champ `point` (dword), adresse du noeud suivant pour un point
	.eqv mTiret, 16		# champ `tiret` (dword), adresse du noeud suivant pour un Tiret
	.eqv mSize, 24 		# taille d'un code morse en octets
	
# miniMorse ######################################################
# une simple arborescence qui permet de decode une sequence morse 
# (restreint aux 4 lettres suivantes)

miniMorse:          		# Déclaration des noeuds de l'arbre
node1:              		# Racine
 	.dword 0 		# aucun caractere associer	
    	.dword node2    	# mPoint
    	.dword node3    	# mTiret
node2:             
    	.dword 'E'      
    	.dword node4    
    	.dword 0     	

node3:              
    	.dword 'T'      
    	.dword 0       	
    	.dword node5  	
		
node4:           
    	.dword 0        
    	.dword node6   	
    	.dword 0 
	
node5:             
    	.dword 0      
    	.dword 0      
    	.dword node7   	
	
node6:            
    	.dword 'S'     
    	.dword 0     	
    	.dword 0     	
	
node7:             
    	.dword 'O'   
    	.dword 0       
    	.dword 0	
    
.text

# decMorse ######################################################
	# IN: a0 adrese d'un code morse Ex. miniMorse
	# IN: a1 adresse d'une chaine de caractere composee de '.' et '-'
	# OUT: a0 le code ASCII du caractere. Ex 'S'
decMorse:
    # Sauvegarder les registres utilisés
	addi sp, sp, -24
    	sd ra, 0(sp)
    	sd s0, 8(sp)
    	sd s1, 16(sp)
    
	mv s0, a0           	# Sauvegarde de l'adresse du code morse
  	mv s1, a1         	# Sauvegarde de l'adresse de la chaîne de caractères
   
decodeLoop:
    	lbu t0, mCar(s1)	# Charger le caractère actuel de la séquence Morse
    	beqz t0, endDecode	# Vérifier si nous avons atteint la fin de la chaîne
    
    # Si le caractère n'est ni '.' ni '-', sortir de la boucle
    	li t1, '.'
    	li t2, '-'
    	beq t0, t1, dot
	beq t0, t2, hyphen
	li a0, '?'
	j dmRet
	
dot:
   	ld t0, mPoint(s0)	# Charge l'adresse du noeud suivant pour un point.
   	beqz t0, decodeFail 	# Si 0, chaîne morse invalide
  	mv s0, t0           	# Met à jour l'adresse du noeud suivant
   	addi s1, s1, 1      	# Avance à la prochaine position dans la chaîne
    	j decodeLoop
    
hyphen:
	ld t0, mTiret(s0)        	# Charge l'adresse du noeud suivant pour un tiret
    	beqz t0, decodeFail 	# Si 0, chaîne morse invalide
    	mv s0, t0           	# Met à jour l'adresse du noeud suivant
    	addi s1, s1, 1      	# Avance à la prochaine position dans la chaîne
    	j decodeLoop
	 
decodeFail:
    	li a0, '?'          	# Chaine morse invalide
    	j dmRet 
	 
endDecode:
	lbu t0, mCar(s0)	# Charge le caractère associé au noeud actuel
	beqz t0, decodeFail
	mv a0, t0
	
# Stack pops
dmRet:
	ld s1, 16(sp)
	ld s0, 8(sp)
	ld ra, 0(sp)
	addi sp, sp, 24
	ret
	
# printMorse ######################################################
	# IN: a0 adresse d'un code morse. Ex. miniMorse
	# OUT: affiche les caracteres en clair tels quels.
printMorse:
    # Sauvegarder les registres utilisés
	addi sp, sp, -24
    	sd ra, 0(sp)
    	sd s0, 8(sp)
    	sd s1, 16(sp)

	mv s0, a0           	# Sauvegarde de l'adresse du code morse
  	li s1, 0		# Valeur boolean, Si c'est == 2 alors c'est vrai, else faux.
  	
 decodeNoeud:
 	lbu t1, mCar(s0)	# Charger le caractère de la séquence Morse
    	beqz t1, nextAdress
	mv a0, t1
	li a7, PrintChar
	ecall 
 nextAdress:
 	ld t0, mPoint(s0)
 	beqz t0, versTiret
 	addi s1, s1, 3
 versTiret:
 	ld t1, mTiret(s0)
 	beqz t1, total
 	addi s1, s1, 1
 	
total:	
	li t0, 4
 	li t1, 3
 	li t2, 1
 	
 	beq s1, t0, adress
 	beq s1, t1, nextDot
 	beq s1, t2, nextHyphen
 	beqz s1, ptmRet
 	
 adress:
	ld t0, mPoint(s0)	# Charge l'adresse du noeud suivant pour un point.
	mv a0, t0
	jal printMorse		# will comeback here after theres no more noeud.

	ld t0, mTiret(s0)
	mv a0, t0
	jal printMorse
	j ptmRet		# we'll go back again.
	
nextDot:
	ld t0, mPoint(s0)	# Charge l'adresse du noeud suivant pour un point.
	mv a0, t0
	jal printMorse
	j ptmRet
nextHyphen:
	ld t0, mTiret(s0)
	mv a0, t0
	jal printMorse
	j ptmRet
# Stack pops
ptmRet:
	ld s1, 16(sp)
	ld s0, 8(sp)
	ld ra, 0(sp)
	addi sp, sp, 24
	ret
	
# newMorse ######################################################
	# IN: nothing
	# OUT: a0 adresse d'un noeud morse vide alloue dans le tas
newMorse:

	addi sp, sp, -16
    	sd ra, 0(sp)
    	sd s0, 8(sp)
    	
	 
	li a7, Sbrk
	li a0, mSize		# alloue a0 octets
	ecall	
	sd zero, mCar(a0)	
	sd zero, mPoint(a0)
	sd zero, mTiret(a0)

	# Stack pops
	

	ld s0, 8(sp)
	ld ra, 0(sp)
	addi sp, sp, 16
	ret

# addMorse ######################################################
	# IN: a0 adresse d'un code morse
	# IN: a1 adresse d'une chaine de caractere composee de '.' et '-'
	# IN: a2 le caractere en clair a associer a cette chaine
addMorse:
# Sauvegarder les registres utilisés
	addi sp, sp, -32
    	sd ra, 0(sp)
    	sd s0, 8(sp)
    	sd s1, 16(sp)
    	sd s2, 24(sp)
 
  	mv s0, a0               # Sauvegarde de l'adresse du code morse
    	mv s1, a1               # Sauvegarde de l'adresse de la chaîne de caractères
    	mv s2, a2               # Sauvegarde du caractère en clair

    # Initialisation du noeud courant au début de l'arbre morse
    	mv t0, s0
    	lbu t1, mCar(s1)      	# Charger le premier caractère de la chaîne morse
    	beqz t1, setChar     	# Si '\0', alors on set le Char au debut de l'adress donne
    	li t5, '.'
    	li t6, '-'
    	beq t1, t5, addDot      # Si '.', aller à dot
    	beq t1, t6, addHyphen  	# Si '-', aller à hyphen

addDot:
    	ld t2, mPoint(t0)       # Charger l'adresse du noeud suivant pour un point
    	beqz t2, createNode     # Si 0, créer un nouveau noeud pour ce point
    	mv t0, t2               # Mettre à jour l'adresse du noeud suivant
    	addi s1, s1, 1          # Avancer à la prochaine position dans la chaîne
    	lb t1, 0(s1)            # Charger le prochain caractère de la chaîne morse
    	beqz t1, setChar       	# Si '\0', aller à set_char
    	beq t1, t5, addDot     	# Si '.', aller à dot
    	beq t1, t6, addHyphen  	# Si '-', aller à hyphen

addHyphen:
    	ld t2, mTiret(t0)       # Charger l'adresse du noeud suivant pour un tiret
    	beqz t2, createNode    	# Si 0, créer un nouveau noeud pour ce tiret
    	mv t0, t2               # Mettre à jour l'adresse du noeud suivant
    	addi s1, s1, 1          # Avancer à la prochaine position dans la chaîne
    	lb t1, 0(s1)            # Charger le prochain caractère de la chaîne morse
    	beqz t1, setChar       	# Si '\0', aller à set_char
    	beq t1, t5, addDot    	# Si '.', aller à dot
    	beq t1, t6, addHyphen  	# Si '-', aller à hyphen

createNode:
    # Allouer un nouveau noeud Morse
    	mv a0, t0
    	jal newMorse
    	mv t2, a0               # Récupérer l'adresse du nouveau noeud
    	lbu t1, mCar(s1)    	# Charger le caractère morse
    	li t5, '.'
    	li t6, '-'
    	beq t1, t5, setDot    	# Si '.', aller à set_dot
    	beq t1, t6, setHyphen 	# Si '-', aller à set_hyphen

setDot:
    sd t2, mPoint(t0)       	# Associer le nouveau noeud comme le prochain pour un point
    j dotEnd

setHyphen:
    sd t2, mTiret(t0)       	# Associer le nouveau noeud comme le prochain pour un tiret
    j hyphenEnd

setChar:
    sb s2, mCar(t0)         	# Associer le caractère en clair au noeud final
    j addmRet

dotEnd:
    lb t1, 0(s1)            	# Charger le prochain caractère de la chaîne morse
    beqz t1, setChar       	# Si '\0', aller à set_char
    j addDot

hyphenEnd:
    lb t1, 0(s1)            	# Charger le prochain caractère de la chaîne morse
    beqz t1, setChar       	# Si '\0', aller à set_char
    j addHyphen

addmRet:  
      	ld s2, 24(sp)
    	ld s1, 16(sp)
    	ld s0, 8(sp)
    	ld ra, 0(sp)
    	addi sp, sp, 32
    	ret

#  printMorseLong ######################################################
	# IN: a0 adresse d'un code morse. Ex. miniMorse
	# OUT: pour chaque caractère en clair la routine affiche : ce caractère,
	# un espace, le code morse associé (composé de . et de -) et en fin un saut de ligne.
printMorseLong:
	# Sauvegarder les registres utilisés
	addi sp, sp, -32
    	sd ra, 0(sp)
    	sd s0, 8(sp)
    	sd s1, 16(sp)
			# Stack les caracteres associe au noeud. 

	.eqv morse, +24
	mv s0, a0          	# Sauvegarde de l'adresse du code morse
  	li s1, 0		# Valeur boolean, Si c'est == 2 alors c'est vrai, else faux.

	
 	lbu t1, mCar(s0)	# Charger le caractère de la séquence Morse
    	beqz t1, nextAdressLg
	mv a0, t1
	li a7, PrintChar
	ecall 
	 # Afficher un espace
    	li a0, ' '
    	li a7, PrintChar
    	ecall
    	# loop pour chercher les caracteres stacker.
#decodeLoop:
	lb a0, +24(sp)
    	li a7, PrintChar
    	ecall 
    	
    #	j decodeLoop
    	
    	
	 # Afficher un saut de ligne
    	li a0, '\n'
    	li a7, PrintChar
    	ecall
    	
nextAdressLg:
 	ld t0, mPoint(s0)
 	beqz t0, versTiretLg
 	addi s1, s1, 3
versTiretLg:
 	ld t1, mTiret(s0)
 	beqz t1, totalLg
 	addi s1, s1, 1
totalLg:	
	li t0, 4
 	li t1, 3
 	li t2, 1
 	
 	beq s1, t0, adressLg
 	beq s1, t1, nextDotLg
 	beq s1, t2, nextHyphenLg
 	beqz s1, ptmRetLg
 	
adressLg:

	ld t0, mPoint(s0)	# Charge l'adresse du noeud suivant pour un point.
	mv a0, t0
	li t1, '.'
	sb t1, 24(sp)
	jal printMorseLong	# will comeback here after theres no more noeud.
	ld t0, mTiret(s0)
	mv a0, t0
	li t1, '-'
	sb t1, 24(sp)
	jal printMorseLong
	j ptmRetLg		# we'll go back again.
	
nextDotLg:
	ld t0, mPoint(s0)	# Charge l'adresse du noeud suivant pour un point.
	mv a0, t0
	li t1, '.'
	sb t1, 24(sp)
	jal printMorseLong
	j ptmRetLg
nextHyphenLg:
	ld t0, mTiret(s0)
	mv a0, t0
	li t1, '-'
	sb t1, 24(sp)
	jal printMorseLong
	j ptmRetLg
# Stack pops
ptmRetLg:

	lb s2, 24(sp)
	ld s1, 16(sp)
	ld s0, 8(sp)
	ld ra, 0(sp)
	addi sp, sp, 32
	ret

