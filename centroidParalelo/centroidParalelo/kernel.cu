
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <windows.h>
#include <conio.h>
#include <time.h>


__global__ void preencheCentroid(float avgDiss[][2], float grupoG[], float centroid[], int qteElementos)
{
	int i = threadIdx.x;

	if (i < qteElementos) {
		avgDiss[i][0] = sqrt(((grupoG[i * 3] - centroid[i * 3]) * (grupoG[i * 3] - centroid[i * 3])) + ((grupoG[i * 3 + 1] - centroid[i * 3 + 1]) * (grupoG[i * 3 + 1] - centroid[i * 3 + 1])));
		avgDiss[i][1] = grupoG[i * 3 + 2];
	}
}


//CODIGO EM C
//*************************************************************************************************************************************//

//Grupos de elementos(objetos) serão identificados por números começando do 0 (ZERO)
//Portanto o primeiro grupo será o grupo 0 
//A estrutura funciona da seguinte forma: float estrutura[grupo][elementos do grupo][informação de cada elemento -> 0 => x, 1 => y, 2 => index]

//para aumentar o numero de grupo é preciso alterar as declarações: maxGrupo e cuboDeDados e tambem a função que preenche o cubo

#define NUM_GRUPOS 90
#define NUM_MAX_ELEMENTOS 100

void preencheEstrutura(float cuboDeDados[][100][3]) {

	for (int i = 0; i < 100; i++)
		for (int j = 0; j < 100; j++)
			for (int k = 0; k < 3; k++)
				cuboDeDados[i][j][k] = -1.f;

}

void insereDadosExternos(float cuboDeDados[][100][3], int dadosExternos[][2]) {

	int index = 0; //identificação única dos elementos começa no 0 (zero) 	

	for (int i = 0; i < 90; i++) {

		for (int j = 0; j < 2; j++)
			cuboDeDados[0][i][j] = dadosExternos[i][j];

		cuboDeDados[0][i][2] = index++;
	}
} //fim da função

void coletaDadosExternos(int dadosExternos[][2]) {

	FILE *arqExterno;

	arqExterno = fopen("C:\\Users\\cliente\\Desktop\\cudaProjects\\centroidParalelo\\centroidParalelo\\duun.txt", "r"); //arquivo cedido pela Hethini (90 pontos)

										 //rotina de erro de abertura de arquivo
	if (arqExterno == NULL)
	{
		printf("Error Reading File\n");
		exit(0);
	}

	for (int i = 0; i < 90; i++)
		for (int j = 0; j < 2; j++)
			fscanf(arqExterno, "%d ", &dadosExternos[i][j]);

} //fim da função

void mostraElementosDoGrupo(float cuboDeDados[][100][3], int grupo) {

	printf("X [0]\tY [1]\tINDEX [2]\n\n"); //cabeçalho dos elementos
	for (int i = 0; i < NUM_MAX_ELEMENTOS; i++) {

		for (int j = 0; j < 3; j++) {

			if (cuboDeDados[grupo][i][j] >= 0)
				printf("%.2f\t", cuboDeDados[grupo][i][j]); //print de todos os elementos do grupo desejado
		}

		if (cuboDeDados[grupo][i][0] >= 0 && cuboDeDados[grupo][i][1] >= 0 && cuboDeDados[grupo][i][2] >= 0)
			printf("\n");

	}

} //fim da função

void insereDadosG(float grupoG[][3], int dadosExternos[][2]) {

	int index = 0;

	for (int i = 0; i < 90; i++) {

		for (int j = 0; j < 2; j++)
			grupoG[i][j] = dadosExternos[i][j];

		grupoG[i][2] = index++;
	}

}

void mostraMatrix(float matrix[][3]) {


	printf("X [0]\tY [1]\tINDEX [2]\n\n"); //cabeçalho dos elementos
	for (int i = 0; i < 90; i++) {

		for (int j = 0; j < 3; j++)
			printf("%.2f\t", matrix[i][j]); //print de todos os elementos de uma matrix

		printf("\n");

	}

}

void mostraMatrixDx(float matrix[][2]) {


	printf("Media [0]\tINDEX [1]\n\n"); //cabeçalho dos elementos
	for (int i = 0; i < 90; i++) {

		for (int j = 0; j < 2; j++)
			printf("%.2f\t\t", matrix[i][j]); //print de todos os elementos de uma matrix

		printf("\n");

	}

}

void inicializaMatrizDiss(float matrizDissimilaridade[][91]) {

	for (int i = 0; i < 91; i++)
		for (int j = 0; j < 91; j++)
			matrizDissimilaridade[i][j] = -1;

}

void preencheMatrizDiss(float matrizDissimilaridade[][91], float grupoG[][3], int qteElementos) {

	//montar uma matriz de dissimilaridade
	//matrizes de dissimilaridade são preenchidas com distâncias euclidianas

	for (int i = 0; i < qteElementos; i++) {

		for (int j = 0; j < qteElementos; j++)
			matrizDissimilaridade[i][j] = sqrt((grupoG[i][0] - grupoG[j][0]) * (grupoG[i][0] - grupoG[j][0]) +
			(grupoG[i][1] - grupoG[j][1]) * (grupoG[i][1] - grupoG[j][1])); // distancia euclidiana

		matrizDissimilaridade[i][qteElementos] = grupoG[i][2]; //ultima posição é reservada para a identificação do elemento
	}
}

void mostraMatrixDiss(float matrix[][91]) {


	printf("X [0]\tY [1]\tINDEX [2]\n\n"); //cabeçalho dos elementos
	for (int i = 0; i < 50; i++) {

		for (int j = 0; j < 15; j++)
			printf("%.2f\t", matrix[i][j]); //print de todos os elementos da matrix

		printf("\n");

	}

}

void preencheMatrizAVG(float matrizDissimilaridade[][91], float avgDiss[][2], int qteElementos) {

	float soma = 0.0;

	for (int i = 0; i < qteElementos; i++) {

		for (int j = 0; j < qteElementos; j++)
			soma += matrizDissimilaridade[i][j];

		avgDiss[i][0] = soma;
		avgDiss[i][1] = matrizDissimilaridade[i][qteElementos];
		soma = 0.0;
	}

}

void mostraMatrixAVG(float matrix[][2]) {


	printf("Media [0]\tINDEX [1]\n\n"); //cabeçalho dos elementos
	for (int i = 0; i < 90; i++) {

		for (int j = 0; j < 2; j++)
			printf("%f\t\t", matrix[i][j]); //print de todos os elementos de uma matrix

		printf("\n");

	}

}

float identificaMaiorDiss(float avgDiss[][2], int qteElementos) {

	float maiorDiss = avgDiss[0][0];
	float id = avgDiss[0][1];

	for (int i = 0; i < qteElementos; i++) {
		if (avgDiss[i][0] > maiorDiss) {
			maiorDiss = avgDiss[i][0];
			id = avgDiss[i][1];
		}
	}

	return id;
}

float identificaMaiorDx(float Dx[][2], int qteElementos) {

	float maiorDx, id;

	maiorDx = Dx[0][0];
	id = Dx[0][1];

	for (int i = 0; i < qteElementos; i++) {

		if (Dx[i][0] > maiorDx) {
			maiorDx = Dx[i][0];
			id = Dx[i][1];
		}
	}

	if (maiorDx <= 0.0) return -1; //retorna negativo se o maior valor for negativo e portanto para o loop
	else	return id;

}

void inicializaMatrizNegativo(float matrizG[][3]) {

	for (int i = 0; i < 90; i++)
		for (int j = 0; j < 3; j++)
			matrizG[i][j] = -1;

}

//inicializa a matriz Dx com -99999.99, numero que é improvavel de acontecer
void inicializaMatrizDx(float Dx[][2]) {

	for (int i = 0; i < 90; i++)
		for (int j = 0; j < 2; j++)
			Dx[i][j] = -99999.99;

}

void deletaElementoDiss(float grupoG[][3], float elementoMaisDissimilar, int *qteElementos, float elementoAux[]) {

	for (int i = 0; i < *qteElementos; i++) {

		if (grupoG[i][2] == elementoMaisDissimilar) {

			//salva em uma estrutura o elemento
			elementoAux[0] = grupoG[i][0];
			elementoAux[1] = grupoG[i][1];
			elementoAux[2] = grupoG[i][2];

			//deleta o elemento com o index desejado do grupo
			for (int j = i; j < *qteElementos - 1; j++) {
				grupoG[j][0] = grupoG[j + 1][0];
				grupoG[j][1] = grupoG[j + 1][1];
				grupoG[j][2] = grupoG[j + 1][2];
			}

			//deleta o ultimo elemento	
			grupoG[*qteElementos - 1][0] = -1.0; //coloca -1 na ultima posição e depois diminui a quantidade de elementos	
			grupoG[*qteElementos - 1][1] = -1.0;
			grupoG[*qteElementos - 1][2] = -1.0; //coloca -1 na ultima posição e depois diminui a quantidade de elementos
			*qteElementos -= 1;
			break;
		}

	}//fim do for de delete

}

void colocaElementoTempG(float tempG[][3], float elementoAux[]) {

	for (int i = 0; i < 90; i++)
		if (tempG[i][0] < 0) {

			tempG[i][0] = elementoAux[0];
			tempG[i][1] = elementoAux[1];
			tempG[i][2] = elementoAux[2];
			break;
		}

}

//partindo do principio que o max de elementos é 90, quando aumentar a quantidade de dados tem que mudar essa funcao
int contaElementosTempG(float tempG[][3]) {

	int quantidade = 0;

	for (int i = 0; i < 90; i++) {

		if (tempG[i][0] < 0)
			break;
		else {
			quantidade++;
		}

	}

	return quantidade;
}

int contaElementosGrupoG(float grupoG[][3]) {

	int quantidade = 0;

	for (int i = 0; i < 90; i++) {

		if (grupoG[i][0] < 0)
			break;
		else {
			quantidade++;
		}

	}

	return quantidade;
}

void preencheDx(float Dx[][2], float grupoG[][3], float tempG[][3], int qteElementos, int qteElementosTempG) {

	float somaG, distG, somaTempG, distTempG;
	int cont;

	somaTempG = 0;
	somaG = 0;
	distTempG = 0;
	distG = 0;
	cont = 0;

	for (int i = 0; i < qteElementos; i++) {

		somaTempG = 0;
		somaG = 0;

		//esse for ira somar as distancias de i com relação a todos os elementos do grupoG
		for (int j = 0; j < qteElementos; j++) {

			if (tempG[j][0] >= 0.f) {

				cont++;
				distTempG = sqrt((grupoG[i][0] - tempG[j][0]) * (grupoG[i][0] - tempG[j][0]) +
					(grupoG[i][1] - tempG[j][1]) * (grupoG[i][1] - tempG[j][1]));
				somaTempG += distTempG;
			} //fim do if

			distG = sqrt((grupoG[i][0] - grupoG[j][0]) * (grupoG[i][0] - grupoG[j][0]) +
				(grupoG[i][1] - grupoG[j][1]) * (grupoG[i][1] - grupoG[j][1]));
			somaG += distG;

		} //fim do segundo for

		  //atribuição da diferença da soma a estrutura D(x)
		somaG /= (qteElementos - 1); // qteElementos-1 pois não se leva em consideração a distancia do elemento de g com relação a ele mesmo
		somaTempG /= qteElementosTempG;

		Dx[i][0] = somaG - somaTempG; //diferença das distancias
		Dx[i][1] = grupoG[i][2]; //index do elemento

	} //fim do primeiro for

	printf("\nCONT COM QTETEMPG: %d\n", cont);
}

void preencheCuboComG(float cuboDeDados[][NUM_MAX_ELEMENTOS][3], float grupoG[][3], int indexMaiorDiametro, int qteElementos) {

	for (int i = 0; i < NUM_MAX_ELEMENTOS; i++) {

		if (i < qteElementos) {

			cuboDeDados[indexMaiorDiametro][i][0] = grupoG[i][0];
			cuboDeDados[indexMaiorDiametro][i][1] = grupoG[i][1];
			cuboDeDados[indexMaiorDiametro][i][2] = grupoG[i][2];

		}
		else {

			cuboDeDados[indexMaiorDiametro][i][0] = -1;
			cuboDeDados[indexMaiorDiametro][i][1] = -1;
			cuboDeDados[indexMaiorDiametro][i][2] = -1;

		}

	}

}

int encontraGrupoVazio(float cuboDeDados[][NUM_MAX_ELEMENTOS][3]) {

	int grupoVazio = -1;

	for (int i = 0; i < 100; i++) {

		if (cuboDeDados[i][0][0] < 0.f) {
			grupoVazio = i;
			break;
		}

	}

	return grupoVazio;

}

void preencheCuboComTempG(float cuboDeDados[][NUM_MAX_ELEMENTOS][3], float tempG[][3], int grupoVazio, int qteElementosTempG) {

	for (int i = 0; i < NUM_MAX_ELEMENTOS; i++) {

		if (i < qteElementosTempG) {

			cuboDeDados[grupoVazio][i][0] = tempG[i][0];
			cuboDeDados[grupoVazio][i][1] = tempG[i][1];
			cuboDeDados[grupoVazio][i][2] = tempG[i][2];

		}
		else {

			cuboDeDados[grupoVazio][i][0] = -1;
			cuboDeDados[grupoVazio][i][1] = -1;
			cuboDeDados[grupoVazio][i][2] = -1;

		}

	}

}

void inicializaMatrizDiametro(float diametroDoGrupo[][2]) {

	for (int i = 0; i < NUM_GRUPOS; i++) {

		diametroDoGrupo[i][0] = -1.f;
		diametroDoGrupo[i][1] = -1.f;

	}
}

int contaElementosCubo(float cuboDeDados[][NUM_MAX_ELEMENTOS][3], int grupo) {

	int cont = 0;

	for (int i = 0; i < NUM_MAX_ELEMENTOS; i++)
		if (cuboDeDados[grupo][i][0] < 0) break;
		else cont++;
		return cont;
}

void preencheMatrizDeDiametro(float cuboDeDados[][NUM_MAX_ELEMENTOS][3], float diametroDoGrupo[][2]) {

	float distanciaParcial, distanciaFinal;
	int quantidadeDeElementosNoGrupo, k;

	k = 0;

	do {

		quantidadeDeElementosNoGrupo = contaElementosCubo(cuboDeDados, k);
		distanciaFinal = 0;

		for (int i = 0; i < 100; i++) {

			distanciaParcial = 0;

			if (cuboDeDados[k][i][0] < 0) break;
			else {

				for (int j = 0; j < 100; j++) {


					if (cuboDeDados[k][j][0] < 0) break;
					else {

						distanciaParcial += sqrt((cuboDeDados[k][i][0] - cuboDeDados[k][j][0]) * (cuboDeDados[k][i][0] - cuboDeDados[k][j][0]) +
							(cuboDeDados[k][i][1] - cuboDeDados[k][j][1]) * (cuboDeDados[k][i][1] - cuboDeDados[k][j][1]));
					}
				}
			}

			distanciaFinal += distanciaParcial;
		}

		//se tiver só um elemento no grupo o diametro é zero
		if (quantidadeDeElementosNoGrupo > 1)
			diametroDoGrupo[k][0] = distanciaFinal / (quantidadeDeElementosNoGrupo*(quantidadeDeElementosNoGrupo - 1));
		else diametroDoGrupo[k][0] = 0.f;

		diametroDoGrupo[k][1] = k;


		k++;
	} while (cuboDeDados[k][0][0] >= 0);

}

float identificaMaiorDiametro(float diametroDoGrupo[][2]) {

	float maiorDiametro = diametroDoGrupo[0][0];
	float id = diametroDoGrupo[0][1];

	for (int i = 0; i < NUM_GRUPOS; i++) {
		if (diametroDoGrupo[i][0] > maiorDiametro) {
			maiorDiametro = diametroDoGrupo[i][0];
			id = diametroDoGrupo[i][1];
		}
	}

	return id;
}

void deletaElementoDx(float Dx[][2], int qteDx, float idDx) {

	for (int i = 0; i < qteDx; i++) {

		if (Dx[i][1] == idDx) {

			//deleta o elemento de Dx
			for (int j = i; j < qteDx - 1; j++) {
				Dx[j][0] = Dx[j + 1][0];
				Dx[j][1] = Dx[j + 1][1];
			}

			Dx[qteDx - 1][0] = -99999.99;
			Dx[qteDx - 1][1] = -99999.99;
			break;

		}


	}

}

int contaElementosDx(float Dx[][2]) {

	int quantidade = 0;

	for (int i = 0; i < 90; i++) {

		if (Dx[i][1] < 0)
			break;
		else {
			quantidade++;
		}

	}

	return quantidade;
}

void preencheGcomMaiorDiametro(float cuboDeDados[][NUM_MAX_ELEMENTOS][3], float grupoG[][3], int indexMaiorDiametro) {

	for (int i = 0; i < 100; i++)
		for (int j = 0; j < 3; j++)
			grupoG[i][j] = cuboDeDados[indexMaiorDiametro][i][j];

}

void calculaCentroid(float grupoG[][3], float centroid[][3], int qteElementos) {

	float centroidGERAL[2], somaX = 0, somaY = 0;

	for (int i = 0; i < qteElementos; i++) {
		somaX += grupoG[i][0];
		somaY += grupoG[i][1];
	}

	centroidGERAL[0] = somaX / qteElementos;
	centroidGERAL[1] = somaY / qteElementos;

	for (int i = 0; i < qteElementos; i++) {
		centroid[i][0] = centroidGERAL[0] - grupoG[i][0];
		centroid[i][1] = centroidGERAL[1] - grupoG[i][1];
		centroid[i][2] = grupoG[i][2];
	}
}

void caculaDistCentroid(float avgDiss[][2], float centroid[][3], float grupoG[][3], int qteElementos) {

	for (int i = 0; i < qteElementos; i++) {

		avgDiss[i][0] = sqrt(((grupoG[i][0] - centroid[i][0]) * (grupoG[i][0] - centroid[i][0])) + ((grupoG[i][1] - centroid[i][1]) * (grupoG[i][1] - centroid[i][1])));
		avgDiss[i][1] = grupoG[i][2];
	}

}

int main() {

	float start, delta;
	float grupoG_array[270], centroid_array[270], (*d_avgDiss)[2], *d_grupoG, *d_centroid;
	float cuboDeDados[100][NUM_MAX_ELEMENTOS][3]; //estrutura principal, x, y e index de cada elemento de cada grupo (AGt)
	float matrizDissimilaridade[91][91]; //estática porém pode ser implementada dinâmica e possui 90+1 espaços pois o ultimo espaço é reservado para o index do elemento
	float grupoG[90][3]; //grupo a ser trabalhado no laço do algoritmo (G) => (x, y, index)
	float tempG[90][3]; //grupo que armazena os elementos que não fazem parte do grupoG
	float grupoTempG[90][3]; //grupo auxiliar utilizado para divisão de grupos
	float avgDiss[90][2]; //matriz que armazena as medias de dissimilaridade de cada elemento
	float maiorDiss[2]; //estrutura que armazena a maior distancia e qual elemento ela pertence
	float elementoAux[3];//estrutura que guarda o elemento que sera deletado e colocado em tempG
	float Dx[90][2]; //matriz que armazenara a diferença das somas das distancias e o index do elemento
	float idDx;
	float diametroDoGrupo[NUM_GRUPOS][2]; //matriz que armazena o diametro e o grupo que ele pertence
	int dadosExternos[90][2]; // matriz que armazena os dados vindo externamente (arquivo .txt) (X)
	int maxGrupos, it, qteElementos, qteElementosTempG, maxIt, indexMaiorDiametro, qteDx;
	float centroid[90][3];

	//definições de variáveis
	maxGrupos = NUM_GRUPOS; //numero maximo de grupos
	it = 0; //numero de iterações
	qteElementos = 90; //quantidade de elementos existentes no grupoG
	qteElementosTempG = 0; //valor inicial, sera mudado posteriormente pela função contaElementosTempG
	idDx = 0; //inicia com algum valor o id que sera retornado em Dx
	maxIt = 0; //numero de iterações do segundo laço, usado para sair do laço caso atinja o numero maximo
	indexMaiorDiametro = 0; //variavel que armazena o index do grupo da estrutura principal com o maior diametro, para posteriormente ser substituido pelo grupoG
							//defaul é 0 (zero) pois todos os dados externos são postos no grupo 0 (zero)
	qteDx = 0; // inicia a quantidade de elementos em Dx

	start = GetTickCount();

	//Preenche as caracteristicas de cada dado com um valor especificado (-1)
	preencheEstrutura(cuboDeDados);

	//pega os dados de um arquivo e coloca na matriz dadosExternos (X), matriz que vai ser posta na estrutura posteriormente	
	coletaDadosExternos(dadosExternos); //(X)

	//insere os dodos externos na estrutura, todos os elementos estão em um só grupo
	insereDadosExternos(cuboDeDados, dadosExternos); // ** (AGt <- X) **

	//insere os dados externos (X) no grupo G (grupoG)
	insereDadosG(grupoG, dadosExternos); // **(G <- X)**

	//mostra elementos da matrix (grupoG)
	//mostraMatrix(grupoG);

	//mostra na tela os elementos de um grupo em especifico
	//mostraElementosDoGrupo(cuboDeDados, 0); 

	//****até este momento os dados estão todos agrupados em um só grupo***//

	//Aqui começa o laço principal (do while)

	do {

		printf("\n\nITERACAO %d\n\n", it);

		maxIt = 0;

		//mostraMatrix(grupoG);

		//inicia matriz centroid
		inicializaMatrizNegativo(centroid);

		//calcula a centroid a qual o elemento tem que ser calculado
		calculaCentroid(grupoG, centroid, qteElementos);

		inicializaMatrizDx(avgDiss);

		//rotina para o paralelismo
		//transforma grupoG e centroid em vetor
		int contador = 0;
		for (int i = 0; i < 90; i++)
			for (int j = 0; j < 3; j++) {
				grupoG_array[contador] = grupoG[i][j];
				centroid_array[contador] = centroid[i][j];
				contador++;
			}

		//aloca memoria no device
		cudaMalloc((float**)&d_avgDiss, 90 * 2 * sizeof(float));
		cudaMalloc((float**)&d_grupoG, 90 * 3 * sizeof(float));
		cudaMalloc((float**)&d_centroid, 90 * 3 * sizeof(float));

		//passa o vetor para o device com cudamemcpy
		cudaMemcpy(d_grupoG, grupoG_array, 90 * 3 * sizeof(float), cudaMemcpyHostToDevice);
		cudaMemcpy(d_centroid, centroid_array, 90 * 3 * sizeof(float), cudaMemcpyHostToDevice);

		dim3 block(90);
		dim3 grid(1);

		preencheCentroid << <grid, block >> > (d_avgDiss, d_grupoG, d_centroid, qteElementos);
		cudaDeviceSynchronize();

		cudaMemcpy(avgDiss, d_avgDiss, (90 * 2) * sizeof(float), cudaMemcpyDeviceToHost);

		// calcula as distancias euclidianas
		//caculaDistCentroid(avgDiss, centroid, grupoG, qteElementos); // CENTROID

		//é necessário uma matriz com essa estrutura (dist, index)
		//preenche a matriz com as médias de distancia de cada elemento
		//preencheMatrizAVG(matrizDissimilaridade, avgDiss, qteElementos); //average linkage -> tera que trocar por centroid linkage	

		//mostra a matrix de medias de distancias
		//mostraMatrixAVG(avgDiss);
		//getch();

																	 //função para encontrar o elemento com a maior media de distancias	
		printf("\nMaior dissimilaridade: %d <- INDEX\n\n", (int)identificaMaiorDiss(avgDiss, qteElementos));

		//inicializa tempG com valores negativos
		inicializaMatrizNegativo(tempG); //todos as posições de tempG estão preenchidas com numeros negativos

										 //identifica o elemento de maior dissimilaridade, o deleta do grupoG e salva o elemento em elementoAux para depois ser posto no grupo tempG
		deletaElementoDiss(grupoG, identificaMaiorDiss(avgDiss, qteElementos), &qteElementos, elementoAux);
		//coloca o elemento em tempG 
		colocaElementoTempG(tempG, elementoAux);

		//preenche as posiões com -99999,99
		inicializaMatrizDx(Dx);

		//conta quantos elementos tem em tempG
		qteElementosTempG = contaElementosTempG(tempG);

		//printf("\nQTE G: %d   QTE tempG: %d\n", qteElementos, qteElementosTempG);

		//matriz que contém a diferença das médias das distancias de cada elemento do grupoG 
		//com relação aos elementos do grupoG menos as medias das distancias do elementos em relação aos elementos do grupo tempG
		preencheDx(Dx, grupoG, tempG, qteElementos, qteElementosTempG); //Dx -> (diferença das medias, index)	

		printf("\nmax it%d\n", maxIt);
		mostraMatrixAVG(Dx);


		//a partir de agora começa o segundo laço que rodara ate que não existam mais valores Dx positivos	
		do {


			maxIt++;

			//conta quantos elementos tem em Dx
			qteDx = contaElementosDx(Dx);


			//conta quantos elementos tem em tempG
			qteElementosTempG = contaElementosTempG(tempG);

			//o elemento que obtiver maior D(x) sera tirado do grupoG e colocado no grupo tempG
			//identifica o maior Dx, se o valor do index for negativo é porque todos os valores de Dx são negativos, portanto deve-se sair do laço
			idDx = identificaMaiorDx(Dx, qteElementos);
			printf("\nMaior elemento de Dx: %f <- INDEX\n\n", idDx);


			//checa se o maior valor de Dx é negativo
			//esse if estara dentro de um laço e quando o valor de idDx for negativo tem que sair do laço
			if (idDx >= 0 && qteElementos > 1) {

				//deleta o elemento de Dx
				deletaElementoDx(Dx, qteDx, idDx);

				printf("EU SOU NUMERO QUATRO");
				//proximo passo é retirar o elemento encontrado do grupoG e coloca-lo em tempG
				//deleta elemento do grupoG
				deletaElementoDiss(grupoG, idDx, &qteElementos, elementoAux);
				//adiciona elemento em tempG
				colocaElementoTempG(tempG, elementoAux);
			}

			//if (it >= 2) getch(); 
			//else 
			//Sleep(500);

			//intrução para o laço nunca cair em loop infinito
			if (maxIt == 100) printf("\n\nNumero maximo de iteracoes atingido.");

		} while (idDx >= 0 && maxIt < 100);

		printf("\nMAXIT TOTAL %d\n", maxIt);


		//todas as variaveis precisam ser atualizadas
		it++;
		printf("\n\nIteracao %d\n\n", it);

		//os grupos precisam ser postos na estrutura principal
		//indexMaiorDiametro é grupo da estrutura principal que deve ser posto o grupoG

		//grupoG é posto na estrutura principal
		preencheCuboComG(cuboDeDados, grupoG, indexMaiorDiametro, qteElementos);

		//procura por um grupo vazio na estrutura principal para se colocar o grupo tempG
		//se retornar um valor negativo é pq nao existem grupos vazios
		printf("\n\nGrupo vazio: %d", encontraGrupoVazio(cuboDeDados));

		//coloca tempG no grupo vazio da estrutura principal
		preencheCuboComTempG(cuboDeDados, tempG, encontraGrupoVazio(cuboDeDados), qteElementosTempG);

		//é necessario medir o diametro dos grupos, escolher o maior e coloca-lo em grupoG
		//preenche todas as posições de diametroGrupo com -1
		inicializaMatrizDiametro(diametroDoGrupo);

		//preenche matriz que contem todos os diametros dos grupo existentes na estrutura principal
		preencheMatrizDeDiametro(cuboDeDados, diametroDoGrupo);


		printf("\n\n");
		for (int i = 0; i < NUM_GRUPOS; i++) {
			for (int j = 0; j < 2; j++)
				printf("%.2f\t", diametroDoGrupo[i][j]);

			printf("\n");
		}

		//encontra grupo com maior diametro
		indexMaiorDiametro = (int)identificaMaiorDiametro(diametroDoGrupo);
		//essa variavel eh importante pois sera a partir dela que preencheremosa estrutura principal
		printf("\nGrupo com maior diametro: %d", indexMaiorDiametro);

		//coloca em G o grupo com maior diametro
		//reinicializa grupoG
		inicializaMatrizNegativo(grupoG);
		//passa o grupo de maior diametro pra G
		preencheGcomMaiorDiametro(cuboDeDados, grupoG, indexMaiorDiametro);

		//atualizar qteElementos de grupoG
		qteElementos = contaElementosGrupoG(grupoG);
		fflush(stdout);

	} while (it <= maxGrupos - 2);

	//printf("\n\nQTE Elementos em G: %d\nQTE Elementos em tempG: %d\n\n", qteElementos, qteElementosTempG);

	//mostraMatrixDx(Dx);
	//mostraMatrix(grupoG);


	//printf ("\n\nGrupo vazio: %d", encontraGrupoVazio(cuboDeDados, maxGrupos));

	//antes de preencher qualquer matriz é necessário reseta-la, ou seja, preenche-la com numeros negativos

	//mostra a estrutura final com os grupos e seus elementos	

	for (int i = 50; i < NUM_GRUPOS; i++) {

		printf("\n\nAGt %d:\n", i);
		mostraElementosDoGrupo(cuboDeDados, i);

	}

	delta = GetTickCount() - start;
	printf("\nTempo: %.2f", delta / 1000);

	getch();
	
} //fim da int main

  //*************************************************************************************************************************************//
