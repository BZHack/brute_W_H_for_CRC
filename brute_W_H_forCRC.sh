#!/bin/bash
#utilisation : ./brute_W_H_forCRC.sh fichier.png
#
#ce script va brute force la largueur et la hauteur de 1 a 3000 pixel pour correspondre au CRC dans l'entete IHDR d'un PNG.
#info utile de l'ente IHDR :
#Width:              4 bytes - 0x00000780  (1920)
#Height:             4 bytes - 0x00000342  (834)
#Bit depth:          1 byte  - 0x04
#Color type:         1 byte  - 0x03
#Compression method: 1 byte  - 0x00
#Filter method:      1 byte  - 0x00
#Interlace method:   1 byte  - 0x00
#
#${chaine:position:longueur}
while [[ -n "$1" ]]
	do
	case $1 in 
	-h|--min-height)
		if [[ "$2" != -*  && "$2" != "" ]] ; then
			minheight=$2
		else
			echo "syntax error"
                        exit 2
                fi
		shift 2
		;;
	-w|--min-width)
		if [[ "$2" != -*  && "$2" != "" ]] ; then
			minwidth=$2
		else
			echo "syntax error"
                        exit 2
                fi
		shift 2
		;;
	-H|--max-height)
		if [[ "$2" != -*  && "$2" != "" ]] ; then
			maxheight=$2
		else
			echo "syntax error"
                        exit 2
                fi
		shift 2
		;;
	-W|--max-width)
		if [[ "$2" != -*  && "$2" != "" ]] ; then
			maxwidth=$2
		else
			echo "syntax error"
                        exit 2
                fi
		shift 2
		;;
	-a|--all)
		if [[ "$2" != -*  && "$2" != "" ]] ; then
			work=all
		else
			echo "syntax error"
                        exit 2
                fi
		shift 2
		;;
	-ow|--only-width)
		if [[ "$2" != -*  && "$2" != "" ]] ; then
			work=width
		else
			echo "syntax error"
                        exit 2
                fi
		shift 2
		;;
	-oh|--only-height)
		if [[ "$2" != -*  && "$2" != "" ]] ; then
			work=height
		else
			echo "syntax error"
                        exit 2
                fi
		shift 2
		;;
	-wh|--width-height)
		if [[ "$2" != -*  && "$2" != "" ]] ; then
			work=width-height
		else
			echo "syntax error"
                        exit 2
                fi
		shift 2
		;;
	-d|--debug)
		if [[ "$2" != -*  && "$2" != "" ]] ; then
			work=debug
		else
			echo "syntax error"
                        exit 2
                fi
		shift 2
		;;
	--help)
		echo "run  brute_W_H_forCRC.sh <option> file.png"
		echo "options :"
		echo "-h	--min-height 	: set the min value for height | default value : 1"
		echo "-w	--min-width		: set the min value for width | default value : 1"
		echo "-H	--max-height 	: set the max value for height | default value : 666"
		echo "-W	--max-width		: set the max value for width | default value : 666"
		echo "#work type [default all] :"
		echo "-oh	--only-height	: bruteforce only the height"
		echo "-ow	--only-width	: bruteforce only the width"
		echo "-wh	--width-height	: bruteforce the width and the height. SLOW"
		echo "-a	--all			: bruteforce the width then the height then the width and the height. VERY SLOW"
		echo "-d	--debug			: print all usefull variables"
		exit 0
		;;
	*)
		fichier="$1"
		if [[ ! -f "$fichier" ]] ; then
			echo "Moukrènes à la glaviouse" 
    		exit 2
		fi
		shift
	;;
	esac
	
done
## Controle qualité des arguments
if [[ -z "$maxheight" ]] ; then
	maxheight=666
fi
if [[ -z "$minheight" ]] ; then
	minheight=1
fi
if [[ -z "$minwidth" ]] ; then
	minwidth=1
fi
if [[ -z "$maxwidth" ]] ; then
	maxwidth=666
fi
if [[ -z "$work" ]] ; then
	work=debug
fi
if [[ "$maxheight" != +([[:digit:]]) || "$minheight" != +([[:digit:]]) || "$minwidth" != +([[:digit:]]) || "$maxwidth" != +([[:digit:]]) ]] ; then
    echo "Moukrènes à la glaviouse"
	echo "##########################################################################"
	echo "run  brute_W_H_forCRC.sh <option> file.png"
	echo "options :"
	echo "-h	--min-height 	: set the min value for height | default value : 1"
	echo "-w	--min-width		: set the min value for width | default value : 1"
	echo "-H	--max-height 	: set the max value for height | default value : 666"
	echo "-W	--max-width		: set the max value for width | default value : 666"
	echo "#work type [default all] :"
	echo "-oh	--only-height	: bruteforce only the height"
	echo "-ow	--only-width	: bruteforce only the width"
	echo "-a	--all			: bruteforce height and width" 
    exit 2
fi

## définition des variables :

fichier_hexa=$(xxd -p ${fichier} | tr -d "\n")
IHDR=$(echo ${fichier_hexa} | head -2  | tr -d "\n" | sed -E 's/89504e470d0a1a0a.{8}(.{42}).*/\1/')
head_IHDR="${IHDR:0:8}"
width_IHDR="${IHDR:8:8}"
height_IHDR="${IHDR:16:8}"
info_IHDR="${IHDR:24:10}"
crc_IHDR="${IHDR:34}"


rm RESULT.png 2> /dev/null

## déclaration des Fonctions
#fonction width only
funk_width() {
	for width in $(seq $minwidth $maxwidth) ; do
		width=$(printf '%x\n' $width)
		for (( i=$((8 - ${#width})); i>=1; i-=1 )) ; do
					buff="${buff}0"
			done
		new_crc=$(printf "$head_IHDR$buff$width$height_IHDR$info_IHDR" | xxd -r -p | rhash --simple - | awk '{print $1}')
		if [[ "$new_crc" = "$crc_IHDR" ]] ; then
			echo "$fichier_hexa" | sed -E 's/(.{32}).{16}(.*$)/\1'"$new_width$new_height"'\2/' | xxd -r -p > RESULT.png 
			echo "Width Recover, check RESULT.png file"
			exit 0 
		fi
		unset buff
	done
}
#fonction height only
funk_height() {
	for height in $(seq $minheight $maxheight) ; do
		height=$(printf '%x\n' $height)
		for (( i=$((8 - ${#height})); i>=1; i-=1 )) ; do
			buff="${buff}0"
		done
		new_crc=$(printf "$head_IHDR$width_IHDR$buff$height$info_IHDR" | xxd -r -p | rhash --simple - | awk '{print $1}')
			if [[ "$new_crc" = "$crc_IHDR" ]] ; then
					echo "$fichier_hexa" | sed -E 's/(.{32}).{16}(.*$)/\1'"$new_width$new_height"'\2/' | xxd -r -p > RESULT.png
					echo "height Recover, check RESULT.png file"
					exit 0
			fi

		unset buff
	done
}
#fonction width and height
funk_all() {
	for valeurh in $(seq $minheight $maxheight) ; do
			height=$(printf '%x\n' $valeurh)
			for (( i=$((8 - ${#height})); i>=1; i-=1 )) ; do
					buffh="${buffh}0"
			done
		new_height=$buffh$height
		unset buffh 
		for valeurw in $(seq $minwidth $maxwidth) ; do
			width=$(printf '%x\n' $valeurw)
				for (( i=$((8 - ${#width})); i>=1; i-=1 )) ; do
						buffw="${buffw}0"
				done
			new_width=$buffw$width
			unset buffw
			#echo $new_width $new_height

				new_crc=$(printf "$head_IHDR$new_width$new_height$info_IHDR" | xxd -r -p | rhash --simple - | awk '{print $1}')
			clear
			echo " CRC : $crc_IHDR H : $new_height W : $valeurw nW : $new_width New CRC : $new_crc"
			#echo $new_crc
				if [[ "$new_crc" = "$crc_IHDR" ]] ; then
						echo "$fichier_hexa" | sed -E 's/(.{32}).{16}(.*$)/\1'"$new_width$new_height"'\2/' | xxd -r -p > RESULT.png
						echo "file recover, check RESULT.png file"
						exit 0
				fi
		done
	done
	}

##début du script :
case $work in
	width)
		echo width
		;;
	height)
		echo height
		;;
	width-height)
		echo width-height
		;;
	all)
		echo all
		;;
	debug)
		fichier_hexa=$(xxd -p ${fichier} | tr -d "\n")
		IHDR=$(echo ${fichier_hexa} | head -2  | tr -d "\n" | sed -E 's/89504e470d0a1a0a.{8}(.{42}).*/\1/')
		head_IHDR="${IHDR:0:8}"
		width_IHDR="${IHDR:8:8}"
		height_IHDR="${IHDR:16:8}"
		info_IHDR="${IHDR:24:10}"
		crc_IHDR="${IHDR:34}"
		echo "
		the maxheight is 	: 	$maxheight 
		the minheight is 	: 	$minheight
		the minwidth is 	:	$minwidth
		the maxwidth is 	:	$maxwidth
		the file is 		:	$fichier
		the 66th first byte	:	${fichier_hexa:0:66}
		the IHDR		:	$IHDR
		the head_IHDR		:	$head_IHDR
		the width_IHDR		:	$width_IHDR
		the height_IHDR		:	$height_IHDR
		the info_IHDR		:	$info_IHDR
		the crc_IHDR		:	$crc_IHDR"
		;;
esac