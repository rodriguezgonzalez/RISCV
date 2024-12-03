# TP2 - Réalisation d'un automate cellulaire pour le jeu de la vie en assembleur RISC-V
# Rafael Rodriguez-Gonzalez RODR14019509 (Groupe 010)
# 
# Ce programme est inspiré du jeu de la vie et utilise libs.s !
# Dans ce jeu, l'évolution des cellules dans une grille bidimensionnelle est 
# déterminée par un ensemble de règles simples basées sur le nombre de cellules
# voisines vivantes ou mortes. Le programme est limité à une grille maximale de dimensions 64x64
###################################################################################
	.data 
	.eqv tabLen, 4160	# Taille de la grille maximale a 64x64 + ( derniere colonne ayant '\n')
grid:   .space tabLen 
tempGrid: 
	.space tabLen
errStr:	
	.string "Grille invalide.\n"
nbreEtape:
	.space 40

	.text 
# Boucle principal qui initialise,calcul l'état suivant et affiche la grille.
mainLoop:
	jal initGrid
	jal storeSteps
	la s0, nbreEtape
	li s11, 0
	mv t6, s8
# Dans cette boucle nous effectuons le nbre total de chaque évolution.
loopExterne:
	lbu s1, (s0)		
	beqz s8, fin		# nbre d'itération total a effectuer.
	bne t6 , s8, nonPremier
	mv s11, s1		# On met le premier nbre dans s4.
	mv a0, s1
	call printInt
	li a0, ':'
	call printChar
	li a0, '\n'
	call printChar

loopInterne:
	beqz s1, rien		# Si s1 == 0 on doit pas faire pas de vérification
	jal checks 
	
rien:	addi s1, s1, -1
	bgtz s1, loopInterne	# tant que l'évolution soit pas complétée.
	jal printGrid		
	addi s8, s8, -1		# on diminue le nbre total d'évolution a effectuer.
	addi s0, s0, 1
	j loopExterne
	
nonPremier:
	add t1, s1, s11
	mv s11, t1
	mv a0, t1
	call printInt
	li a0, ':'
	call printChar
	li a0, '\n'
	call printChar
	j loopInterne
mainErr:
	la a0, errStr
	call printString
	li a0, 1
	call exit

#########
initGrid:
	addi sp, sp, -32
	sd ra, 0(sp)
	sd s0, 8(sp)
	sd s1, 16(sp)
	sd s2, 24(sp)
	
# On initialise la grille principal et la grille temporaire en meme temps.
	la s0, grid
	la s7, tempGrid
	li s1, tabLen
	li s3, 0		# expression booleen pour savoir si c'est la premiere ligne.
	li s4, 0		# le nbre total de colonne + la colonne avec '\n'
	li s5, 0		# represente le nbre total de ligne.
	
initGridLoop:
	call readChar
	li t1, '.'
	beq a0, t1, colonne
	li t1, '#'
	beq a0, t1, colonne
	li t1, '\n'
	beq a0, t1, totalCol
	j mainErr
	
totalCol:
	lbu t2, -1(s0)
	beq t1, t2, ici		# Si le caractere avant est aussi un '\n' alors on branch pour partir.
	addi s5, s5, 1		#calcule le nbre de lignes
	addi t3, t3, 1
	beqz s3, firstRow	# verifie si c'est la premiere ligne
	bne t3, s4, mainErr	# verifie que  t3 = s4 sinon c'est une erreur. 
	li t3, 0		# recommence a compter pour next row.
	j store
firstRow:
	mv s4, t3		# Transfer t3 vers s4, cela correspondra à la longueur de la première ligne
	li s3, 1		# S3 sera maintenant faux car ce ne sera plus la première ligne
	li t3, 0		# On remet t3 a 0 pour compter longueur tableau.
	j store
colonne:
	addi t3, t3, 1		# calcule nbre de colonnes	
store:	sb a0, (s0)		
	sb a0, (s7)
	addi s0, s0, 1
	addi s7, s7, 1
	j initGridLoop
				
ici:	la s0, grid		# et ajoute un `\0` a la fin des lignes
	la s7, tempGrid
	addi t2, s4, -1		# on a besoin de -1 colonne pour inserer le vide dans la derniere colonne.
	add s0, s0, t2		# Ajoute a l'adresse + nbr de colonne necessaire
	add s7, s7, t2
	mv t1, s5
	li s2, '\0'
initGridLoop2:
	sb s2, (s0)
	sb s2, (s7)
	add s0, s0, s4		#Ajoute le nb necessaire pour arriver au prochain '\0'
	add s7, s7, s4
	addi t1, t1, -1
	bgtz t1, initGridLoop2
	
	ld ra, 0(sp)
	ld s0, 8(sp)
	ld s1, 16(sp)
	ld s2, 24(sp)
	addi sp, sp, 32
	ret
	
###########
storeSteps: 
	addi sp, sp, -32
	sd ra, 0(sp)
	sd s0, 8(sp)
	sd s1, 16(sp)
	sd s2, 24(sp)
	
	li s8, 0
	la s0, nbreEtape
steps:	call readInt			
	bltz  a0, end
	sb a0, (s0)
	addi s0, s0, 1
	addi s8, s8, 1			
	j steps
end:	
	ld ra, 0(sp)
	ld s0, 8(sp)
	ld s1, 16(sp)
	ld s2, 24(sp)
	addi sp, sp, 32
	ret

###########
#Permet de faire les verification d'evolution pour chaque cellule
checks:
	addi sp, sp, -32
	sd ra, 0(sp)
	sd s0, 8(sp)
	sd s1, 16(sp)
	sd s2, 24(sp)

	li t1, 3
	bne s4, t1, stdSize 	# Si la taille du tableau et == 2 alors on verifie seulement les coins.
	jal checkCoins
	j returnMain
stdSize:	
	jal checkCoins
	jal checkBord
	jal checkCentre
	
returnMain:		
	ld ra, 0(sp)
	ld s0, 8(sp)
	ld s1, 16(sp)
	ld s2, 24(sp)
	addi sp, sp, 32
	ret
	
#########
checkCoins:
	addi sp, sp, -40
	sd ra, 0(sp)
	sd s0, 8(sp)
	sd s1, 16(sp)
	sd s2, 24(sp)
	sd s3, 32(sp)
	
	la s0, grid
	la s1, tempGrid
	li s2, 0
	li t2, '#'
#####	
# On verifie la partie superieur du tableau.
TopLeft:lbu t1, 1(s0)		
	bne  t1, t2, next	# Si ce n'est pas égal, cela signifie que la cellule n'est pas vivante..
	addi s2, s2, 1		# ajoute 1 au compteur de cellules vivantes
next:	add s0, s0, s4
	lbu t1, (s0)
	bne t1, t2, next2	
	addi s2, s2, 1
next2:	lbu t1, 1(s0)
	bne t1, t2, next3
	addi s2, s2, 1
next3:	la s0, grid
	lbu t1, (s0)
	li t2, '#'
	bne t1, t2, dead	 # Brancher vers 'dead' si la cellule du coin gauche est morte.
	li t2, 2
	beq t2, s2, TopRight 	# Si s2 = 2, alors la cellule reste vivante et nous passons au coin suivant.
	li t2, 3
	beq t2, s2, TopRight
	li t3, '.'
	sb t3, (s1)		# Nous stockons la cellule morte et passons au coin suivant
	j TopRight	
dead:	li t2, 3
	bne t2, s2, TopRight	# Si s2 n'est pas égal à 3, alors la cellule reste morte.	
	li t2, '#'
	sb t2, (s1)		
	j TopRight		# On a fini avec le premier coin mtn a verifier le 2ier
#######
	
TopRight:
	li s2, 0
	li t2, '#'
	add s0, s0, s4		
	addi s0, s0, -3		# Pour vérifier le bit précédent et voir s'il est vivant.
	lbu t1, (s0)
	bne t1, t2, nextR	# Si ce n'est pas égal, cela signifie que la cellule est morte.
	addi s2, s2, 1		
nextR:	add s0, s0, s4
	lbu t1, (s0)
	bne t1, t2, nextR2	
	addi s2, s2, 1
nextR2:	lbu t1, 1(s0)
	bne t1, t2, nextR3
	addi s2, s2, 1
nextR3:	sub s0, s0, s4
	lbu t1, 1(s0)
	bne t1, t2, dead2	
	li t2, 2
	beq t2, s2, botLeft 	
	li t2, 3
	beq t2, s2, botLeft
	li t3, '.'
	add s1, s1, s4
	addi s1, s1, -2		
	sb t3, (s1)		
	j botLeft	
dead2:  
	li t2, 3
	bne t2, s2, botLeft		
	add s1, s1, s4
	addi s1, s1, -2
	li t1, '#'
	sb t1, (s1)
	j botLeft	
#######
botLeft:	
	la s0, grid
	la s1, tempGrid
	li s2, 0
	li s3, 0
	li t2, '#'
	mul s3, s4, s5
	sub s3, s3, s4 
	add s0, s0, s3
	add s1, s1, s3
	
	lbu t1, 1(s0)		
	bne t1, t2, nextB	# if not equal it means cell is dead
	addi s2, s2, 1		# adding 1 cells alived in counter.
nextB:	sub s0, s0, s4
	lbu t1, (s0)
	bne t1, t2, nextB2	#branch to next cells
	addi s2, s2, 1
nextB2:	lbu t1, 1(s0)
	bne t1, t2, nextB3
	addi s2, s2, 1
nextB3:
	add s0, s0, s4
	lbu t1, (s0)
	bne t1, t2, dead3 	# Branch to dead Si la cellule du coin droit est morte.
	li t2, 2
	beq t2, s2, botRight 	# if s2 = 2 than cells stays alive and we move on next corner
	li t2, 3
	beq t2, s2, botRight
	li t3, '.'
	sb t3, (s1)		#we Store dead cell and move onto the next corner.
	j botRight	
dead3:  
	li t2, 3
	bne t2, s2, botRight	#if s2 not equal to 3 than stays dead	
	li t1, '#'
	sb t1, (s1)		#else you store alive cell in s1.
	j botRight		
	
#######
botRight:
	la s0, grid
	la s1, tempGrid
	li s2, 0
	li s3, 0
	li t2, '#'
	mul s3, s4, s5 
	addi s3, s3, -2 	#Now we have position corner bot right.
	add s0, s0, s3
	add s1, s1, s3
		
	lbu t1, -1(s0)		
	bne t1, t2, nextBD	# if not equal it means cell is alive.
	addi s2, s2, 1		# adding 1 cells alived in counter.
nextBD:	sub s0, s0, s4
	lbu t1, (s0)
	bne t1, t2, nextBD2	#branch to next cells
	addi s2, s2, 1
nextBD2:lbu t1, -1(s0)
	bne t1, t2, nextBD3
	addi s2, s2, 1
nextBD3:
	add s0, s0, s4
	lbu t1, (s0)
	bne t1, t2, deadBD 	# Branch to dead Si la cellule du coin droit est morte.
	li t2, 2
	beq t2, s2, retour 	# if s2 = 2 than cells stays alive and we move go back
	li t2, 3
	beq t2, s2, retour
	li t3, '.'
	sb t3, (s1)		#we Store dead cell and go back.
	j retour	
deadBD:  
	li t2, 3
	bne t2, s2, retour	#if s2 not equal to 3 than stays dead	
	li t1, '#'
	sb t1, (s1)		#else you store alive cell in s1.
retour:	
	ld ra, 0(sp)
	ld s0, 8(sp)
	ld s1, 16(sp)
	ld s2, 24(sp)
	ld s3, 32(sp)
	addi sp, sp, 40
	ret
##########	
checkBord:
ebreak
	addi sp, sp, -40
	sd ra, 0(sp)
	sd s0, 8(sp)
	sd s1, 16(sp)
	sd s2, 24(sp)
	sd s3, 32(sp)
	
	la s0, grid
	la s1, tempGrid
	addi t3, s4, -3		# Connaitre la longeur du bord superieur a verifier.
	
checkTop:
	li t2,'#'
	li s2,0
	bltz t3, checkGauche
	addi s0, s0, 1		#On commence a verfier au deuxieme case. (pas les coins)
	addi s1, s1, 1
	lbu t1, 1(s0)		# premier a verfier cote droit.
	bne t1, t2, empty	# Not equal so not alive
	addi s2, s2, 1		# compteur nbre cellules vivantes voisines.	
empty:	lbu t1, -1(s0)
	bne t1, t2, empty1
	addi s2, s2, 1
empty1: add s0, s0, s4
	lbu t1, (s0) 
	bne t1, t2, empty2
	addi s2, s2, 1
empty2: lbu t1, -1(s0)	
	bne t1, t2, empty4
	addi s2, s2, 1
empty4: lbu t1, 1(s0)	
	bne t1, t2, verifCell
	addi s2, s2, 1
	
verifCell:
	addi t3, t3, -1
	sub s0, s0, s4
	lbu t1, (s0)
	bne t1, t2, libre	# Si ce n'est pas egale c pcq la cellule est dead
	li t2, 2
	beq s2, t2, checkTop				
	li t2, 3
	beq s2, t2, checkTop 	# stays alive and move onto next 
	li t2, '.'
	sb t2, (s1)
	j checkTop				
libre:											
	li t2, 3
	bne s2, t2, checkTop	 # if its  != 3 then stays dead
	li t2, '#'
	sb t2, (s1)
	j checkTop
	
checkGauche:
	la s0, grid
	la s1, tempGrid
	li s3, 0		
	addi s3, s5, -2		# How many time it will do the loop.
	
loopG:	li t2, '#'
	li s2, 0		# nbre de voisin en vie.
	beqz s3, checkDroit
	lbu t1, (s0)
	bne t1, t2, vide
	addi s2, s2, 1
vide:	lbu t1, 1(s0)
	bne t1, t2, vide2
	addi s2, s2, 1
vide2:	add s0, s0, s4
	lbu t1, 1(s0)
	bne t1, t2, vide3
	addi s2, s2, 1
vide3:	add s0, s0, s4
	lbu t1, (s0)
	bne t1, t2, vide4
	addi s2, s2, 1
vide4:	lbu t1, 1(s0)
	bne t1, t2, verifLeft
	addi s2, s2, 1	
verifLeft:	
	addi s3, s3, -1
	sub s0, s0, s4	
	add s1, s1, s4
	lbu t1, (s0)
	bne t1, t2, libre2 	
	li t2, 2
	beq s2, t2, loopG				
	li t2, 3
	beq s2, t2, loopG 	# stays alive and move onto next 
	li t2, '.'
	sb t2, (s1)
	j loopG				
libre2:											
	li t2, 3
	bne s2, t2, loopG 	# if its  != 3 then stays dead
	li t2, '#'
	sb t2, (s1)
	j loopG
	
checkDroit:
	la s0, grid
	la s1, tempGrid
	add s0, s0, s4
	addi s0, s0, -3
	add s1, s1, s4		# S0 et S1 mtn sur cote extreme droit.
	addi s1, s1, -3
	addi s3, s5, -2		# How many time it will do the loop.
		
loopR:  li t2, '#'
	li s2, 0
	bltz s3, checkBot
	lbu t1, (s0)
	bne t1, t2, vider
	addi s2, s2, 1
vider:	lbu t1, 1(s0)
	bne t1, t2, vide2r
	addi s2, s2, 1
vide2r:	add s0, s0, s4
	lbu t1, (s0)
	bne t1, t2, vide3r
	addi s2, s2, 1
vide3r:	add s0, s0, s4
	lbu t1, (s0)
	bne t1, t2, vide4r
	addi s2, s2, 1
vide4r: lbu t1, 1(s0)
	bne t1, t2, verifRight
	addi s2, s2, 1	
	
verifRight:		
	addi s3, s3, -1
	sub s0, s0, s4
	add s1, s1, s4
	lbu t1, 1(s0)
	bne t1, t2, libre3	# Si ce n'est pas egale c pcq la cellule est dead
	li t2, 2
	beq s2, t2, loopR				
	li t2, 3
	beq s2, t2, loopR 	# stays alive and move onto next 
	li t2, '.'
	sb t2, 1(s1)
	j loopR				
libre3:										
	li t2, 3
	bne s2, t2, loopR 	# if its  != 3 then stays dead
	li t2, '#'
	sb t2, 1(s1)
	j loopR
	
checkBot:
	la s0, grid
	la s1, tempGrid
	mul s3, s4, s5
	sub s3, s3, s4
	add s0, s0, s3		# Pour positionner dans le coin inferieur.
	add s1, s1, s3
	addi t3, s4, -3		# Connaitre la longeur du bord inferieur a verifier.
	
loopbot:
	li t2, '#'
	li s2, 0
	bltz t3, return
	addi s0, s0, 1		#On commence a verfier au deuxieme case. (pas les coins)
	addi s1, s1, 1
	lbu t1, 1(s0)		# premier a verfier cote droit.
	bne t1, t2, emptyb	# Not equal so not alive
	addi s2, s2, 1		#compteur nbre cellules vivantes voisines.	
emptyb:	lbu t1, -1(s0)
	bne t1, t2, empty1b
	addi s2, s2, 1
empty1b:sub s0, s0, s4
	lbu t1, (s0) 
	bne t1, t2, empty2b
	addi s2, s2, 1
empty2b:lbu t1, -1(s0)	
	bne t1, t2, empty4b
	addi s2, s2, 1
empty4b:lbu t1, 1(s0)	
	bne t1, t2, verifCellBot
	addi s2, s2, 1
	
verifCellBot:
	addi t3, t3, -1
	add s0, s0, s4
	lbu t1, (s0)
	bne t1, t2, libreB	# Si ce n'est pas egale c pcq la cellule est dead
	li t2, 2
	beq s2, t2, loopbot				
	li t2, 3
	beq s2, t2, loopbot 	# stays alive and move onto next 
	li t2, '.'
	sb t2, (s1)
	j loopbot				
libreB:											
	li t2, 3
	bne s2, t2, loopbot 	# if its  != 3 then stays dead
	li t2, '#'
	sb t2, (s1)
	j loopbot


return:	ld ra, 0(sp)
	ld s0, 8(sp)
	ld s1, 16(sp)
	ld s2, 24(sp)
	ld s3, 32(sp)
	addi sp, sp, 40
	ret
#############
checkCentre:
	addi sp, sp, -40
	sd ra, 0(sp)
	sd s0, 8(sp)
	sd s1, 16(sp)
	sd s2, 24(sp)
	sd s3, 32(sp)
	
	la s0, grid
	la s1, tempGrid
	add s0, s0, s4
	add s1, s1, s4		# On commence tjrs a partir de la deuxieme ligne.
	li s3, 0
	li t5, 0
	addi s3, s4, -3		# S3 = LONGUEUR de la ligne verifier.
	addi t5, s5, -2		# connaitre le nbre de lignes pour faire des loop.
	
centerLoop:			#Verification des 8 voisins.
	beqz s3, centerLoop2
	beqz t5, return2
	li t2, '#'
	li s2, 0		#Total de voisins vivant
	addi s0, s0, 1		#On commence a verfier au deuxieme case. (pas les coins)
	addi s1, s1, 1
	lbu t1, -1(s0)		# premier a verfier.
	bne t1, t2, free1	# Not equal so not alive
	addi s2, s2, 1		#compteur nbre cellules vivantes voisines.	
free1:	lbu t1, 1(s0)
	bne t1, t2, free2
	addi s2, s2, 1
free2:  add s0, s0, s4
	lbu t1, (s0)
	bne t1, t2, free3
	addi s2, s2, 1
free3:	lbu t1, 1(s0)	
	bne t1, t2, free4
	addi s2, s2, 1
free4:	lbu t1, -1(s0)
	bne t1, t2, free5
	addi s2, s2, 1
free5:	sub s0, s0, s4
	sub s0, s0, s4
	lbu t1, (s0)	
	bne t1, t2, free6
	addi s2, s2, 1
free6: 	lbu t1, 1(s0)	
	bne t1, t2, free7
	addi s2, s2, 1
free7: 	lbu t1, -1(s0)	
	bne t1, t2, verifCenter
	addi s2, s2, 1
verifCenter:
	addi s3, s3, -1		# total nbre d'iteration par ligne -1.
	add s0, s0, s4		# Pour retourner au point initiale et evaluer si la cellule principale est morte ou vivante.
	lbu t1, (s0)
	bne t1, t2, libre8	# Si ce n'est pas egale c pcq la cellule est dead
	li t2, 2
	beq s2, t2, centerLoop				
	li t2, 3
	beq s2, t2, centerLoop # stays alive and move onto next 
	li t2, '.'
	sb t2, (s1)
	j centerLoop				
libre8:											
	li t2, 3
	bne s2, t2, centerLoop # if its  != 3 then stays dead
	li t2, '#'
	sb t2, (s1)
	j centerLoop
	
centerLoop2:
	addi s3, s4, -3
	addi s0, s0, 3
	addi s1, s1, 3
	addi t5, t5, -1
	j centerLoop
return2:
	la s0, grid
	la s7, tempGrid
	mul t3, s4, s5
	
# permet de mettre a jour la grille principal avec la temporaire.	
transfer:		
	lbu t1, (s7)
	sb t1, (s0)
	addi s0, s0, 1
	addi s7, s7, 1
	addi t3, t3, -1
	bnez t3, transfer
	
	ld ra, 0(sp)
	ld s0, 8(sp)
	ld s1, 16(sp)
	ld s2, 24(sp)
	ld s3, 32(sp)
	addi sp, sp, 40
	ret

############
# On affiche la grille ligne par ligne
printGrid:
	addi sp, sp, -48
	sd ra, 0(sp)
	sd s0, 8(sp)
	sd s1, 16(sp)
	sd s2, 24(sp)
	sd s4, 32(sp)
	sd s5, 40(sp)
	
	la s0, tempGrid
	
printGridLoop:
	mv a0, s0
	call printString
	li a0, '\n'
	call printChar
	
	add s0, s0, s4 		# for next line to be printed
	addi s5, s5, -1
	bgtz s5, printGridLoop

	ld ra, 0(sp)
	ld s0, 8(sp)
	ld s1, 16(sp)
	ld s2, 24(sp)
	ld s4, 32(sp)
	ld s5, 40(sp)
	addi sp, sp, 48
	ret
fin : 
	li 	a0, 0
	call exit
