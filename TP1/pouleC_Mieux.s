# TP1 - Programme assembleur RISC-V inpiré du jeu poule-poule.
# Rafael Rodriguez-Gonzalez RODR14019509 
#
# Le programme inpiré du jeu poule-poule. Prend en entrée une séquence de cartes 
# représentées sous forme de differents caractères afin de calculer combien d'oeufs sont disponible.

	# Appels des systeme RARS utilises
	.eqv PrintInt, 1
	.eqv PrintChar, 11
	.eqv ReadChar, 12
	.eqv Exit, 10
	
	# Initialisation des registres.
   	li s0, 0 	# Valeur total du nombre d'oeuf.  
	li s1, 0 	# Valeur du nombre lu a sauvegarder.
	li s2, 0 	# booleen de vrai ou faux
  	li s3, 0	# nb total de poules en jeu. 
  	li s4, 0	# nb de renard en jeu
  	li s5, 0	# nb de chien de garde disponible
  	li s6, 0	# nb de ver disponible dans la partie
  	
  # Boucle principal qui lit les caracteres et agit en consequence des divers cartes.
loop:  	
  	#Lit un caractere depuis l'entree standard.
  	li a7,ReadChar
   	ecall 	  	
	li t0, '0'	# si le caractere represente un nombre entre 0 et 9 alors il va calculer le nombre et le sauvegarder.
	blt a0, t0, Erreur
	li t0, '9'
	bgt a0, t0, cartes
	
	# Si ce n'est pas des cartes ou une erreur alors on calcule la valeur du nombre.
	addi a0, a0, -48# Pour calculer la valeur de nombre on fait -48 puisque c'est la valeur du 0 en code ascii.		
	li t0, 10
	mul s1, s1, t0			
	add s1, s1, a0
	li s2, 1 	# change le booleen pour vrai
	j loop
  
 # Compare les caracteres lu pour verifier si c'est une option disponible pour jouer, sinon c'est une erreur.
cartes:
	li t5, 'q'		
	beq a0, t5, fin	
	li t5, 'o'	
	beq a0, t5, oeuf	
	li t5, 'a'	
	beq a0, t5, affiche
	li t5, 'p'	
	beq a0, t5, poule
	li t5, 'r'	
	beq a0, t5, renard
	li t5, 'c'	
	beq a0, t5, chien
	li t5, 'v'	
	beq a0, t5, ver
	
	j Erreur
		

oeuf:	# verifie si il y a un nombre valide dans le registre s2, sinon c'est on ajoute seulement 1 oeuf.
	li t1,0
	beq s2,t1,add_un
	add s0,s0,s1	# sinon s2 sera a 1 ce qui veut dire qu'il y a un nombre devant alors faut add un plus grand nb.
	li s1,0		#remettre le nombre sauvegarder a 0.
	li s2,0
	j loop
	
add_un:	
	addi s0,s0,1	# total + 1 oeuf de plus.
	j loop


poule:
	beqz s0, loop 	#Si s0 = 0 alors il n'y rien a faire et on retourne dans la loop principal.
	beqz s2, une_poule
	bge s0, s1, des_poules	
	bge s6, s1, restera_vers#branch if there's more or equal amount of worms  than chickens.
	sub s1, s1, s6			#else it means that theres more chickens so we have to put worms to 0 and to chickens = chickens-worms
	li s6, 0
	blt s1, s0, poule
	sub s0,s0,s0			# Si on est rendu ici , il y a plus de poules que d'oeufs. Alors les oeufs = 0
	add s3,s3,s0
	li s1,0	
	li s2,0
	j loop
	
des_poules:	# soustraction normal de oeufs moins les poules.
	bge s6,s1, restera_vers	#branch if there's more or equal amount of worms  than chickens.	
	sub s1,s1,s6				#else it means that theres more chickens so we have to put worms to 0 and to chickens = chickens-worms
	li s6,0
	blt  s0,s1,poule
	sub s0,s0,s1
	add s3,s3,s1	# ajoute le nb de poules en jeu dans le registre s3
	li s1,0	
	li s2,0
	j loop
restera_vers:
	sub s6,s6,s1	#soustrait les vers qui sont mange par les poules.
	li s1,0	
	li s2,0
	j loop
	
	
une_poule:
	# si il n'y a pas  de ver disponible alors la poule vas cacher un oeuf, sinon elle vas manger le ver et partir.
	blez s6, un_oeuf
	addi s6,s6,-1
	j loop
un_oeuf:
	addi s0,s0,-1	# la poule cache 1 oeuf et donc il y a -1 oeuf dispo.
	addi s3,s3,1	# Ajoute 1 poule en jeu.
	j loop
	
renard:
	bnez s5, renard_go	#si il au moins 1 chien alors le renard s'enfuit
	beqz s3, loop	# si il y a 0 poule alors le renard s'en vas.
	beqz s2,un_renard
	bge s3,s1,des_renards	# branch Si les poules sont plus nombreux ou egal aux renards.
	add s0,s0,s3
	sub s3,s3,s3
	li s1,0	
	li s2,0
	j loop
		
des_renards:	
	# soustraction normal de poules moins les renards.
	sub s3,s3,s1
	add s0,s0,s1
	li s1,0	
	li s2,0
	j loop
	
un_renard:
	addi s3,s3,-1	# -1 une poule de dispo puisqu'elle fuit.
	addi s0,s0,1	# 1 oeuf est mtn decouvert
	j loop
	
renard_go:
	beqz s2, un_renard_go		# il ya just 1 renard.
	bge s5,s1, reste_chien		# soit il ya +de chien que de renard ou il ya plus de renard que de chiens. 
	sub s1, s1, s5				#sinon il vas rester des renards. et pas de chien. alors on recommence la loop.
	li s5, 0				
	bgtz s1, renard
	li s1,0	
	li s2,0
	j loop
un_renard_go:
	addi s5,s5,-1
	j loop
			
reste_chien:
	sub s5,s5,s1	#dans ce cas-ci il ya += chien. alors tous les renard fui.
	li s1,0	
	li s2,0	
	j loop

chien: 
	beqz s1,un_chien
	add s5,s5,s1
	li s1,0	
	li s2,0
	j loop
un_chien:
	addi s5,s5,1	#ajoute 1 chien de garde en memoire
	j loop
ver:
	bgtz s2,des_vers
	addi s6,s6,1	#ajoute 1 ver en memoire
	j loop
des_vers:
	add s6,s6,s1
	li s1,0	
	li s2,0
	j loop

affiche:
	#Affiche le nombre d'oeufs disponible en jeu suivi d'un saut de ligne.
	beqz s2, print	
	beqz  s1, loop
print:	li a7, PrintInt
	mv a0,s0
	ecall
	li a7, PrintChar
	li a0, '\n'
	ecall
	beqz s2,loop	# si s2 <= 0 alors il fallait juste print 1 fois et on retourne au main loop.
	addi s1,s1,-1
	bnez s1, affiche
	li s2,0
	j loop
	
Erreur: 
        # Affiche Err et termine le programme
	li a7, PrintChar
        li a0, 'E'
        ecall
        li a0, 'r'
        ecall
        li a0, 'r'
        ecall
        
fin :	
      	# Termine le programme
	li a7, Exit
	li a0,0
       	ecall	
	
	
	
	
