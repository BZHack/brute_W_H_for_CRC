# brute_W_H_for_CRC
ce script va brute force la largueur et la hauteur pour correspondre au CRC dans l’entête IHDR d'un PNG.

	run  brute_W_H_forCRC.sh <option> file.png
	options :
	-h	--min-height 	: set the min value for height | default value : 1
	-w	--min-width	: set the min value for width | default value : 1
	-H	--max-height 	: set the max value for height | default value : 6666
	-W	--max-width	: set the max value for width | default value : 6666
	#work type [default all] :
	-oh	--only-height	: bruteforce only the height
	-ow	--only-width	: bruteforce only the width
	-wh	--width-height	: bruteforce the width and the height. SLOW
	-a	--all			: bruteforce the width then the height then the width and the height. VERY SLOW
	-d	--debug			: print all usefull variables

il y a un ficher démo pour vos tests : corupted.png

le résultat doit etre la meme image que : Noobosaurus_R3x.png

Merci a https://twitter.com/noobosaurusr3x pour son autorisation.

