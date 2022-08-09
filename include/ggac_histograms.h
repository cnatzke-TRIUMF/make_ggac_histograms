#ifndef GAMMAGAMMAHISTOGRAMS_H
#define GAMMAGAMMAHISTOGRAMS_H

#include "TGriffin.h"
#include "TGriffinBgo.h"
#include "TVector3.h"
#include <vector>

int ProcessData();
TFile *CreateOutputFile(int runNumber);
void DisplayLoadingMessage();
int GetAngleIndex(double angle);
void GenerateAngleMap(double distance);
int GetClosest(int val1, int val2, std::vector<double> vec, double target);
void OpenRootFile(std::string fileName);
void AutoFileDetect(std::string fileName);
void PrintUsage(char *argv[]);

TGriffin *fGrif = NULL;
TGriffinBgo *fGriffinBgo = NULL;

std::vector<std::pair<double, int>> fAngleMap;

float energy_temp = 0;
std::vector<float> energy_vec; // vector which contains the energy values
std::vector<long> time_vec;    // vector which contains the time values
std::vector<TVector3> pos_vec; // vector which contains the position values
// std::vector<int> detector_vec; // vector which contains the detector values
float duplicate_check_energy[64];

int det; // GRIFFIN detector number

int checkMix, lgsize, event_mixing_depth = 11;
std::vector<std::vector<float>> last_grif_energy;
std::vector<std::vector<TVector3>> last_grif_position;
#endif
