#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
#include <vector>
#include <time.h>
#include <random>
#include <fstream>
#include <algorithm>
#include <sys/stat.h>
#include <sys/types.h>
#include <chrono>
#define TAP_NUM 37 //tap_num
//宣告一個tap[37]buffer用來儲存coeff from matlab kaiser window
double tap[TAP_NUM] = {-0.00100187361118782
,-0.00363302636454365
,4.29834681927617e-18
,0.00645230235555201
,0.00322804312416619
,-0.00883853938538118
,-0.00934957765569822
,0.00905091823358614
,0.0184278692118741
,-0.004749379300005
,-0.0297224389635515
,-0.00711153250496541
,0.0417210572275703
,0.0316499089461282
,-0.0524286678959256
,-0.0847962253442247
,0.0598465232410926
,0.310829527969206
,0.4375
,0.310829527969206
,0.0598465232410926
,-0.0847962253442247
,-0.0524286678959256
,0.0316499089461282
,0.0417210572275703
,-0.00711153250496541
,-0.0297224389635515
,-0.004749379300005
,0.0184278692118741
,0.00905091823358614
,-0.00934957765569822
,-0.00883853938538118
,0.00322804312416619
,0.00645230235555202
,4.29834681927617e-18
,-0.00363302636454365
,-0.00100187361118782};
using namespace std;

//dump signal file to txt file
template<typename T>
void transfer_sig2txt(const std::string& filename, const T& strm) {
    std::ofstream f(filename, std::ios_base::out);
    if (!f.is_open()) {
        std::cerr << "Error opening file: " << filename << std::endl;
        return;
    }
    for (const auto& signal : strm) {
        f << signal << "\n";
    }
    f.close();
}

//add noise
void addnoise(vector<double>& inputsignal){
    double max = 0;
    for(auto a : inputsignal){
        if( fabs(a)>max ) max = fabs(a);
    }
    const double mean = 0.0;
    const double stddev = 0.1;
    std::default_random_engine generator;
    std::normal_distribution<double> dist(mean, stddev);
    // Add Gaussian noise
    for (auto& input : inputsignal) {
        input = input + dist(generator)/100;
    }    
}
//quant function
double quant(vector<double>& strm, int WL, bool noise = false) {
    if (noise) {
        addnoise(strm); 
    }

    double maxVal = *std::max_element(strm.begin(), strm.end(), 
        [](double a, double b) { return std::fabs(a) < std::fabs(b); });

    double scale = (std::pow(2, WL - 1) - 1) / maxVal;

    for (auto& input : strm) {
        input *= scale;
    }

    return scale;
}

void de_quant(vector<double>& strm, double scale){
    for(auto&input : strm){
        input = input / scale;
    }   
}

void truncate(vector<double>& strm){
    //truncation
    for(auto&input : strm){
        input = floor(input);
    }    
}

void shift(vector<double>& strm, int shift){
    for(auto&input: strm){
        input = input * pow(2,shift);
    }
}

void shift_buffer(std::vector<double>& buffer, double strm) {
    for (int i = buffer.size() - 1; i > 0; --i) {
        buffer[i] = buffer[i - 1];
    }
    buffer[0] = strm;
}

double accumulate_output(const std::vector<double>& buffer ,int N) {
    double acc = 0.0;
    for (int i = 0; i < N; ++i) {
        acc += tap[i] * buffer[i];
    }
    return acc;
}

std::vector<double> filt_fp(const std::vector<double>& strm , int N) {
    std::vector<double> outputSignal;
    std::vector<double> inputBuffer(N, 0);  
    for (auto input : strm) {
        shift_buffer(inputBuffer, input);
        double output = accumulate_output(inputBuffer, 37);
        outputSignal.push_back(output);
    }

    transfer_sig2txt("./4matlab/outputsignal_fp.txt", outputSignal);
    return outputSignal;
}

double calculateQuantizedOutput(const std::vector<double>& inputBuffer,std::vector<double>& tapCopy, int shiftBits) {
    double output = 0.0;
    for (size_t i = 0; i < inputBuffer.size(); ++i) {
        double temp = tapCopy[i] * inputBuffer[i];
        temp *= std::pow(2, shiftBits);
        output += std::floor(temp);
    }
    return output;
}


vector<double> filt_quant(vector<double> strm,int WL,int MAC_WL ,int N){
	vector<double> outputsignal , tap_copy;
    //複製一份tap[]用於計算
	for(int i=0;i<N;i++){
		tap_copy.push_back(tap[i]);
	}
	double input_scale = quant(strm,WL,true);//bool = true為add noise
	double tap_scale  = quant(tap_copy,WL);// 不需加上noise

	truncate(strm);
    //quant input and dump file
    transfer_sig2txt("./data/HW_input.txt",strm);

	truncate(tap_copy);
    //quant tap and dump file
    transfer_sig2txt("./data/HW_coef.txt",tap_copy);
	std::vector<double> inputBuffer(N, 0);
	int shift_bit = MAC_WL - (WL*2); 
    for(auto input : strm){
        shift_buffer(inputBuffer, input);
        double output = calculateQuantizedOutput(inputBuffer, tap_copy, shift_bit);
        outputsignal.push_back(output); 
		truncate(outputsignal); 
    }
    //dump golden data
	transfer_sig2txt("./data/HW_golden.txt",outputsignal);
    
    //de_quant
	shift(outputsignal, (-1*shift_bit)); 
    de_quant(outputsignal,input_scale*tap_scale);
    //de_quant output to fixed
	transfer_sig2txt("./4matlab/outputsignal_fixed.txt",outputsignal);
	return outputsignal;
}

double SNR_cal(vector<double> strm_fixed,vector<double> strm_fp){
	double SNR_value;
	double numerator = 0;
	double denumerator = 0;
	for(auto input: strm_fp){
		numerator  += pow(input,2);
	}
	for(int i=0;i<500;i++){
		denumerator += pow((strm_fp[i]-strm_fixed[i]),2); 
	}
	SNR_value = 10*log10( numerator /denumerator);
    return SNR_value;
}

void random_input(std::vector<double> &inputsignal, int length) {
    // 使用当前时间作为种子
    unsigned seed = std::chrono::system_clock::now().time_since_epoch().count();
    std::default_random_engine generator(seed);

    std::uniform_real_distribution<double> distribution(-50, 50);
    std::vector<double> randArray(length);
    double sumOfSquares = 0;
    
    // 生成随机信号并计算平方和
    for (int i = 0; i < length; i++) {
        randArray[i] = distribution(generator);
        sumOfSquares += randArray[i] * randArray[i];
    }
    
    // 计算平均功率并规范化信号
    double avgpower = sumOfSquares / length;
    for (int i = 0; i < length; i++) {
        inputsignal.push_back(randArray[i] / sqrt(avgpower));
    }
    
    std::cout << "Average power = " << 1 << std::endl;
}


void find4WL(const std::vector<double>& inputSignal, int N) {
    std::vector<double> SNR, WL, MAC_SNR, MAC_WL;
    //This loop finds the input word length (WL)

    for (int wl = 0; wl < 32; ++wl) {
        auto fp = filt_fp(inputSignal , 37);
        auto fixed = filt_quant(inputSignal, wl, 32, 37);
        SNR.push_back(SNR_cal(fixed, fp));
        WL.push_back(wl);
    }
    
    //choose inWL =15bits
    //This loop finds the output word length (WL)

    for (int mac_wl = 15; mac_wl < 32; ++mac_wl) {
        auto fp = filt_fp(inputSignal,37);
        auto fixed = filt_quant(inputSignal, 15, mac_wl, 37); 
        MAC_SNR.push_back(SNR_cal(fixed, fp));
        MAC_WL.push_back(mac_wl);
    }

    //this dump txt file for matlab
    transfer_sig2txt("./4matlab/find4inWL.txt", SNR);
    transfer_sig2txt("./4matlab/WL.txt", WL);
    transfer_sig2txt("./4matlab/find4macWL.txt", MAC_SNR);
    transfer_sig2txt("./4matlab/MAC_WL.txt", MAC_WL);
}

int main() {
    //I use Linix system so it is "mkdir"
    mkdir("./data", 0755);
    mkdir("./4matlab", 0755);
 
    std::vector<double> inputSignal;
    random_input(inputSignal, 500);
    //for input spectrum
    transfer_sig2txt("./4matlab/inputsignal.txt", inputSignal);

    //WL test
    find4WL(inputSignal,37);

    auto fp = filt_fp(inputSignal,37);
    auto fixed = filt_quant(inputSignal, 15, 20, 37);

    return 0;
}