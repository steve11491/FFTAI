#ifndef __FILE_UTILS__
#define __FILE_UTILS__

#include <string>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <vector>
#include <cstdint>


using namespace std;

template<typename T>
int WriteFile(string path,T *oriaddr,int size){
    ofstream write_file;
    char buffer[1024];
    write_file.open(path,ios::trunc);
    if(!write_file.is_open()){
        cout<<"\033[31mCan't open file "<<path<<"\033[0m"<<endl;
        return -1;
    }
    for(int i = 0; i < size; i++){
	sprintf(buffer, "%d", *(oriaddr+i));
        write_file <<buffer << " " ;
    }
    write_file.close();
    cout<<"write file "<<path<<" successful!"<<endl;
    return 0;
}

template<typename T>
int ReadFile(string path,T *oriaddr,int size){
    ifstream read_file;
    string str;
    read_file.open(path);
    if(!read_file.is_open()){
        printf("can not open the file");
        return -1;
    }
    for(int i = 0; i < size; i++){
        read_file >> str;
        *(oriaddr+i) = atoi(str.c_str());;

        if(read_file.eof()){
            //cout<<"\033[31mflie "<<path<<" length short, need_size:"<<size<<",file_size:"<<i<<"\033[0m"<<endl;
            printf("length short");
            read_file.close();
            return -1;
        }
    }
    read_file.close();
    return 0;
//    cout<<"read file "<<path<<" successful!"<<endl;
}




//void ReadFile(){
//    bool flag = false;
//    int i;
//    read_file.open(file_path);
//    if(!read_file.is_open()){
//        cout<<"can't open file "<<file_path<<endl;
//        return;
//    }
//    for(i = 0; i < file_size; i++){
//        if(flag){
//            cout<<"flie "<<file_path<<" length short, need_size:"<<file_size<<",file_size:"<<i<<endl;
//            read_file.close();
//            return;
//        }
//        read_file >> *(file_oriaddr+i);
//        if(read_file.eof()){
//            flag = true;
//        }
//    }
//    if(!flag){
//        cout<<"flie "<<file_path<<" length long"<<endl;
//    }
//    read_file.close();
//}

#endif