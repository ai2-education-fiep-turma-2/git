#!/usr/bin/env bash

source functions.sh
atual=""
declare -A companhia
declare -A aeroporto
declare -A aeroporto_cancelamentos
declare -A num_atrasos_voo
declare -A num_cancelamentos_voo
declare -A tempo_atraso_voo
declare -A num_atrasos_dia_semana
declare -A tempo_atraso_dia_semana
declare -A num_atrasos_dia_mes
declare -A tempo_atraso_dia_mes

companhia["teste"]=1
aeroporto["teste"]=1
aeroporto_cancelamentos["teste"]=1
aeroporto_cancelamentos["teste2"]=1
num_atrasos_voo[0]=1
num_cancelamentos_voo[0]=1
tempo_atraso_voo[0]=1
num_atrasos_dia_semana[0]=1
tempo_atraso_dia_semana[0]=1
num_atrasos_dia_mes[0]=1
tempo_atraso_dia_mes[0]=1


#Feature .3
function atrasos_por_companhia(){
	companhia_mais_atrasos="teste"

	#Para cada uma das companhia com atrasos, faça
	for key in ${!companhia[@]};do
		#Se a companhia atual tiver mais atrasos que a companhia com mais atrasos
        	if [[ ${companhia[$key]} -gt ${companhia[$companhia_mais_atrasos]} ]]; then
			#A companhia atual se torna a companhia com mais atrasos
			companhia_mais_atrasos=$key
		fi
	done

	echo "A Companhia com mais atrasos foi:"
	echo $companhia_mais_atrasos
}

#Feature .4
function atrasos_por_aeroporto(){
        aeroporto_mais_atrasos="teste"

	#Para cada uma dos aeroportos com atrasos, faça
        for key in ${!aeroporto[@]};do
		#Se o aeroporto atual tiver mais atrasos que o aeroporto com mais atrasos
                if [[ ${aeroporto[$key]} -gt ${aeroporto[$aeroporto_mais_atrasos]} ]]; then
			#O aeroporto atual se torna a companhia com mais atrasos
                        aeroporto_mais_atrasos=$key
                fi
        done

        echo "O Aeroporto com mais atrasos foi:"
        echo $aeroporto_mais_atrasos

				aeroporto_atual=""
				aeroporto_mais_cancelamentos="teste"
				for key in ${!aeroporto_cancelamentos[@]};do
					if [[ ${aeroporto_cancelamentos[$key]} -gt ${aeroporto_cancelamentos[$aeroporto_mais_cancelamentos]} ]]; then
						aeroporto_mais_cancelamentos=$key
					fi
				done

				echo "O aeroporto com mais cancelamentos foi: $aeroporto_mais_cancelamentos com ${aeroporto_cancelamentos[$aeroporto_mais_cancelamentos]} cancelamentos"
}

#Feature 3
function ler_companhia(){
	#Realiza a leitura do arquivo carriers.csv linha por linha, atribuindo a primeira célula para a variável sigla, e a segunda célula para a variável nome
	while IFS=, read -r sigla nome; do
		#declara a string aspas com valor "
		aspas="\""
		#se a "sigla" for igual a sigla lida
	        if [[ "$aspas$1$aspas" == $sigla ]]; then
			#se já existir o registro desta companhia
        	        if [ "${#companhia[@]}" -ne 0 ]; then
				#adiciona +1 nos valores de atraso
                	        companhia["$1"]=$((companhia["$1"] + 1))
	                else
				#cria a companhia com valor 1
	                        companhia["$1"]=1
        	        fi
	        fi
	done < carriers.csv

	#Feature .2
	#imprime a leitura atual do dicionário de companhias e atrasos (somente para testes)
	for key in ${!companhia[@]};do
        	echo "Companhia  = ${key}"
	        echo "Atrasos = ${companhia[$key]}"
	done
}

#Feature 4
function ler_aeroporto(){
	#Realiza a leitura do arquivo airports.csv linha por linha, atribuindo a primeira célula para a variável sigla, e a segunda célula para a variável nome, o restante ficará na variável cidade
	while IFS=, read -r sigla nome cidade; do
	        #mesma lógica da função ler_companhia
		aspas="\""
	  if [[ "$aspas$1$aspas" == $sigla ]]; then
			if [ "${#aeroporto[@]}" -ne 0 ]; then
				aeroporto["$1"]=$((aeroporto["$1"] + 1))
			else
				aeroporto["$1"]=1
			fi

			if [ "${#aeroporto_cancelamentos[@]}" -ne 0 ]; then
					if [ $2 -ne 0 ]; then
						aeroporto_cancelamentos["$1"]=$((aeroporto_cancelamentos["$1"] + 1))
					fi
			else
				if [ $2 -ne 0 ]; then
					aeroporto_cancelamentos["$1"]=1
				fi
			fi

		fi
	done < airports.csv

	#Feature .1
	for key in ${!aeroporto[@]};do
		echo "Aeroporto  = ${key}"
		echo "Atrasos = ${aeroporto[$key]}"
	done
}

while getopts ":dtncavsm" opt; do
    case ${opt} in
        d ) # Download de datasets
            shift
	    #Feature 1
            download_datasets $1
            test -f /2006.tar && echo "$FILE já descompactado."
	    test -f /2007.tar && echo "$FILE já descompactado."
	    bzip2 -d 2006.tar.bz2
            bzip2 -d 2007.tar.bz2
	    mv 2006.tar 2006
	    mv 2007.tar 2007
        ;;
        t ) # process option t
        ;;
	n ) # Listar atrasos por ano
	     #Feature 2
	     echo "$2"
	     contador_atrasos=0
	     #Realiza a leitura linha por linha do arquivo que o usuário decidir utilizar ($2) e armazena os valores separados por , para cada célula do array arr
	     while IFS=, read -ra arr; do
		#Se o ano do dado for igual a entrada do usuário
		if [[ ${arr[0]} -eq $2 ]]; then
			#se o valor de atraso for positivo
			if [[ ${arr[14]} -gt 0 ]]; then
				#Conta mais um atraso
				contador_atrasos=$(($contador_atrasos + 1))
			fi
		fi
	     done < $2
	     echo "O número de atrasos neste ano foram:"
	     echo "$contador_atrasos"

	;;
	c ) # Dados por Companhia aérea

	     #Mesma lógico do caso -n
	     while IFS=, read -ra arr; do
                if [[ ${arr[0]} -eq $2 ]]; then
                        if [[ ${arr[14]} -gt 0 ]]; then
				#chama a função ler_companhia passado por parâmetro a sigla da companhia com atraso
				ler_companhia ${arr[8]}
			fi
                fi

		#conta apenas 100 linhas (Para teste)
                contador=$((contador + 1))
	        if [[ $contador -gt 100  ]];then
        	        break
	        fi

             done < $2
	     #chama a função que verifica o número de atrasos_por_companhia
	     atrasos_por_companhia
	;;
	a ) # Atraso por Aeroporto

	    #Mesma lógica do caso -n
	    while IFS=, read -ra arr; do
                if [[ ${arr[0]} -eq $2 ]]; then
                        if [[ ${arr[14]} -gt 0 ]]; then
                                #chama a função ler_aeroporto passando por parâmetro a sigla do aeroporto com atraso
																ler_aeroporto ${arr[17]} ${arr[21]}
                        fi
												ler_aeroporto ${arr[17]} ${arr[21]}
                fi

		#conta apenas 100 linhas (Para teste)
                contador=$((contador + 1))
                if [[ $contador -gt 100  ]];then
                        break
                fi

             done < $2
	     #chama a função que verifica o número de atrasos_por_aeroporto
	     atrasos_por_aeroporto
	;;
	v ) # Atraso por voo
			while IFS=, read -ra arr; do
								if [[ ${arr[0]} -eq $2 ]]; then
												if [[ ${arr[14]} -gt 0 ]]; then
													if [ "${#num_atrasos_voo[@]}" -ne 0 ]; then
															num_atrasos_voo[${arr[9]}]=$((num_atrasos_voo[${arr[9]}] + 1))
															tempo_atraso_voo[${arr[9]}]=$((tempo_atraso_voo[${arr[9]}] + ${arr[14]}))
													else
															num_atrasos_voo[${arr[9]}]=1
															tempo_atraso_voo[${arr[9]}]=${arr[14]}
													fi
												fi
												if [ "${#num_cancelamentos_voo[@]}" -ne 0 ]; then
													num_cancelamentos_voo[${arr[9]}]=$((num_cancelamentos_voo[${arr[21]}] + 1))
												else
													num_cancelamentos_voo[${arr[9]}]=1
												fi
								fi

		            #conta apenas 100 linhas (Para teste)
								contador=$((contador + 1))
								if [[ $contador -gt 100  ]];then
												break
								fi

			done < $2

			#Feature .5
			maior=0
			maior_media=0
			for key in ${!num_atrasos_voo[@]};do
				echo "Voo  = ${key}"
				echo "Média de atraso = $((tempo_atraso_voo[$key] / num_atrasos_voo[$key]))"
				media_atual=$((tempo_atraso_voo[$key] / num_atrasos_voo[$key]))
				maior_media=$((tempo_atraso_voo[$maior] / num_atrasos_voo[$maior]))
				if [[ media_atual -gt maior_media ]]; then
					maior=$key
				fi
			done

			echo "O voo com maior atraso em média foi: $maior com média de: $maior_media"

			voo_mais_cancelamentos="teste"
			for key in ${!num_cancelamentos_voo[@]};do
				if [[ ${num_cancelamentos_voo[$key]} -gt ${num_cancelamentos_voo[$voo_mais_cancelamentos]} ]]; then
					voo_mais_cancelamentos=$key
				fi
			done

			echo "O voo com mais cancelamentos foi: $voo_mais_cancelamentos com ${num_cancelamentos_voo[$voo_mais_cancelamentos]} cancelamentos"

	;;
	s ) # Atraso por dia da semana

	while IFS=, read -ra arr; do
						if [[ ${arr[0]} -eq $2 ]]; then
										if [[ ${arr[14]} -gt 0 ]]; then
											if [ "${#num_atrasos_dia_semana[@]}" -ne 0 ]; then
													num_atrasos_dia_semana[${arr[3]}]=$((num_atrasos_dia_semana[${arr[3]}] + 1))
													tempo_atraso_dia_semana[${arr[3]}]=$((tempo_atraso_dia_semana[${arr[3]}] + ${arr[14]}))
											else
													num_atrasos_dia_semana[${arr[3]}]=1
													tempo_atraso_dia_semana[${arr[3]}]=${arr[14]}
											fi
										fi
						fi

						#conta apenas 100 linhas (Para teste)
						contador=$((contador + 1))
						if [[ $contador -gt 100  ]];then
										break
						fi

	done < $2

	maior=0
	maior_media=0
	for key in ${!num_atrasos_dia_semana[@]};do
		echo "Dia da semana  = ${key}"
		echo "Média de atraso = $((tempo_atraso_dia_semana[$key] / num_atrasos_dia_semana[$key]))"
		media_atual=$((tempo_atraso_dia_semana[$key] / num_atrasos_dia_semana[$key]))
		maior_media=$((tempo_atraso_dia_semana[$maior] / num_atrasos_dia_semana[$maior]))
		if [[ media_atual -gt maior_media ]]; then
			maior=$key
		fi
	done

	echo "O dia da semana com maior atraso em média foi: $maior com média de: $maior_media"
	;;

	m )

		while IFS=, read -ra arr; do
							if [[ ${arr[0]} -eq $2 ]]; then
											if [[ ${arr[14]} -gt 0 ]]; then
												if [ "${#num_atrasos_dia_semana[@]}" -ne 0 ]; then
														num_atrasos_dia_mes[${arr[2]}]=$((num_atrasos_dia_mes[${arr[2]}] + 1))
														tempo_atraso_dia_mes[${arr[2]}]=$((tempo_atraso_dia_mes[${arr[2]}] + ${arr[14]}))
												else
														num_atrasos_dia_mes[${arr[2]}]=1
														tempo_atraso_dia_mes[${arr[2]}]=${arr[14]}
												fi
											fi
							fi

							#conta apenas 100 linhas (Para teste)
							contador=$((contador + 1))
							if [[ $contador -gt 100  ]];then
											break
							fi

		done < $2

		maior=0
		maior_media=0
		for key in ${!num_atrasos_dia_mes[@]};do
			echo "Dia do Mês  = ${key}"
			echo "Média de atraso = $((tempo_atraso_dia_mes[$key] / num_atrasos_dia_mes[$key]))"
			media_atual=$((tempo_atraso_dia_mes[$key] / num_atrasos_dia_mes[$key]))
			maior_media=$((tempo_atraso_dia_mes[$maior] / num_atrasos_dia_mes[$maior]))
			if [[ media_atual -gt maior_media ]]; then
				maior=$key
			fi
		done

		echo "O dia do Mês com maior atraso em média foi: $maior com média de: $((tempo_atraso_dia_mes[$maior] / num_atrasos_dia_mes[$maior]))"
	;;
        \? ) echo "Usage: flight-delays.sh [-d] [-t]"
        ;;
  esac
done
