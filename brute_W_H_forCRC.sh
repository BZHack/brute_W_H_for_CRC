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
rm RESULT.png 2> /dev/null
fichier="$1"
fichier_hexa=$(xxd -p ${fichier} | tr -d "\n")
IHDR=$(echo ${fichier_hexa} | head -2  | tr -d "\n" | sed -E 's/89504e470d0a1a0a.{8}(.{42}).*/\1/')
head_IHDR="${IHDR:0:8}"
width_IHDR="${IHDR:8:8}"
height_IHDR="${IHDR:16:8}"
info_IHDR="${IHDR:24:10}"
crc_IHDR="${IHDR:34}"

for width in {1..3000} ; do
	width=$(printf '%x\n' $width)
	for (( i=$((8 - ${#width})); i>=1; i-=1 )) ; do
                buff="${buff}0"
        done
	new_crc=$(printf "$head_IHDR$buff$width$height_IHDR$info_IHDR" | xxd -r -p | rhash --simple - | awk '{print $1}')
	if [[ "$new_crc" = "$crc_IHDR" ]] ; then
		echo "$fichier_hexa" | sed -E 's/(.{58}).{8}(.*$)/\1'"$new_crc"'\2/' | xxd -r -p > RESULT.png 
		echo "Width Recover, check RESULT.png file"
		exit 0 
	fi
	unset buff
done
for height in {1..3000} ; do
	height=$(printf '%x\n' $height)
	for (( i=$((8 - ${#height})); i>=1; i-=1 )) ; do
		buff="${buff}0"
	done
	new_crc=$(printf "$head_IHDR$width_IHDR$buff$height$info_IHDR" | xxd -r -p | rhash --simple - | awk '{print $1}')
        if [[ "$new_crc" = "$crc_IHDR" ]] ; then
                echo "$fichier_hexa" | sed -E 's/(.{58}).{8}(.*$)/\1'"$new_crc"'\2/' | xxd -r -p > RESULT.png
                echo "height Recover, check RESULT.png file"
                exit 0
        fi

	unset buff
done
echo $crc_IHDR
for valeurh in {1..3000} ; do
        height=$(printf '%x\n' $valeurh)
        for (( i=$((8 - ${#height})); i>=1; i-=1 )) ; do
                buffh="${buffh}0"
        done
	new_height=$buffh$height
	unset buffh 
	for valeurw in {1..3000} ; do
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


