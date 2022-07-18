//////////////////////////////////////////////////////////////////////////////////
// Extracts the gamma gamma tree and processes events into histograms
//
// Run this script in the parent directory of the experiment
// (e.g. /data4/S9038)
//
// Author:        Connor Natzke (cnatzke@triumf.ca)
// Creation Date: Monday April 6, 2020	T13:33:58-07:00
// Last Update:   Monday April 6, 2020	T13:42:13-07:00
// Usage:
//
//////////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include "TFile.h"
#include "TGRSIUtilities.h"
#include "TParserLibrary.h" // needed for GetRunNumber
#include "TMath.h"
#include "TH2.h"
#include "TH1.h"
#include "TObjArray.h"
#include "TParserLibrary.h"
#include "TEnv.h"
//#include "TGRSIRunInfo.h"

#include "progress_bar.h"
#include "ggac_histograms.h"
#include "Notifier.h"
#include "LoadingMessenger.h"

Notifier *notifier = new Notifier;
/**************************************************************
 * Lists all of the files in a directory matching the run number
 * (i.e. extracts all subruns for processing)
 *
 * @param dir_name   Directory name
 * @param ext        Extension of the files (default = ".root")
 ***************************************************************/
int main(int argc, char **argv)
{

	if (argc == 1)
	{ // no inputs given
		PrintUsage(argv);
		return 0;
	}

	// makes time retrival happy
	std::string grsi_path = getenv("GRSISYS");
	if (grsi_path.length() > 0)
	{
		grsi_path += "/";
	}
	grsi_path += ".grsirc";
	gEnv->ReadFile(grsi_path.c_str(), kEnvChange);

	TParserLibrary::Get()->Load();

	for (auto i = 1; i < argc; i++)
		AutoFileDetect(argv[i]);

	if (!gChain)
		std::cout << "No gChain found" << std::endl;
	if (!gChain->GetEntries())
		std::cout << "Found gChain, but no entries retrieved" << std::endl;

	if (!gChain || !gChain->GetEntries())
	{
		std::cerr << "Failed to find anything. Exiting" << std::endl;
		return 1;
	}

	int process_check;
	process_check = ProcessData();
	if (process_check != 0)
	{
		std::cerr << "Data did not process correctly ... exiting" << std::endl;
		return 1;
	}
	return 0;

} // main

/******************************************************************************
 * Process events from gamma-gamma tree
 *
 *****************************************************************************/
int ProcessData()
{
	std::string fName = gChain->GetCurrentFile()->GetName();
	int run_number = GetRunNumber(fName.c_str());
	TObjArray gammaGammaSubList(0);
	TObjArray gammaGammaMixedList(0);

	float ggHigh = 100.;  // max time difference for gamma gamma
	float bgLow = 500.;	  // min time difference for gamma gamma
	float bgHigh = 2000.; // max time diff for gamma gamma bg

	float gbin = 5500.;
	float gLow = 0.;
	float gHigh = gbin;

	std::cout << "Processing run " << run_number << " with " << gChain->GetNtrees() << " file(s)" << std::endl;

	long analysis_entries = gChain->GetEntries();

	if (gChain->FindBranch("TGriffin"))
	{
		gChain->SetBranchAddress("TGriffin", &fGrif);
		if (fGrif != NULL)
		{
			std::cout << "Succesfully found TGriffin branch" << std::endl;
		}
		else
		{
			std::cout << "Could not find TGriffin branch ... exiting" << std::endl;
			return 1;
		}
	}
	if (gChain->FindBranch("TGriffinBgo"))
	{
		gChain->SetBranchAddress("TGriffinBgo", &fGriffinBgo);
		if (fGriffinBgo != NULL)
		{
			std::cout << "Succesfully found TGriffinBgo branch" << std::endl;
		}
		else
		{
			std::cout << "Could not find TGriffinBgo branch ... exiting" << std::endl;
			return 1;
		}
	}

	// display loading message
	LoadingMessenger load_man;
	load_man.DisplayLoadingMessage();

	/* Creates a progress bar that has a width of 70,
	 * shows '=' to indicate completion, and blank
	 * space for incomplete
	 */
	ProgressBar progress_bar(analysis_entries, 70, '=', ' ');
	// for (auto i = 0; i < analysis_entries/10000; i++) {
	TGriffinHit *grif_hit;
	TH2D *sum_hist = new TH2D("sum_hist", "", gbin, gLow, gHigh, gbin, gLow, gHigh);
	TH2D *sum_hist_mixed = new TH2D("sum_hist_mixed", "", gbin, gLow, gHigh, gbin, gLow, gHigh);
	for (auto i = 0; i < analysis_entries; i++)
	{
		// retrieve entries from trees
		gChain->GetEntry(i);

		// Filling required Lists and preproccessing data
		for (auto j = 0; j < fGrif->GetSuppressedMultiplicity(fGriffinBgo); ++j)
		{
			grif_hit = fGrif->GetSuppressedHit(j);
			det = grif_hit->GetArrayNumber() - 1;
			if (grif_hit->GetKValue() != 700)
			{
				continue;
			} // removes GRIFFIN hits pileup events
			energy_temp = grif_hit->GetEnergy();
			// skipping duplicate events
			if (abs(energy_temp - duplicate_check_energy[det]) < 0.3)
			{
				continue;
			}
			duplicate_check_energy[det] = energy_temp;

			// Add small randomness to allow for rebinning
			energy_temp += ((double)rand() / RAND_MAX - 0.5);

			energy_vec.push_back(energy_temp);
			pos_vec.push_back(grif_hit->GetPosition(145.0));
			time_vec.push_back(grif_hit->GetTime());
			// detector_vec.push_back(det);
		}

		// Filling histograms
		for (unsigned int g1 = 0; g1 < energy_vec.size(); ++g1)
		{
			// gamma-gamma matrices
			for (unsigned int g2 = 0; g2 < energy_vec.size(); ++g2)
			{
				if (g1 == g2)
					continue;

				double angle = pos_vec.at(g1).Angle(pos_vec.at(g2)) * 180. / TMath::Pi();
				if (angle < 0.0001)
					continue;

				int angleIndex = GetAngleIndex(angle, fAngleCombinations);
				double ggTime = TMath::Abs(time_vec.at(g1) - time_vec.at(g2));

				// check for bad angles
				if (angleIndex == -1)
				{
					std::cout << "Bad Angle" << std::endl;
					continue;
				}

				// Generating/Retrieving histograms
				TH2F *myhist = ((TH2F *)0); // NULL
				if (angleIndex < gammaGammaSubList.GetSize())
					myhist = ((TH2F *)(gammaGammaSubList.At(angleIndex)));
				if (!myhist)
				{
					myhist = new TH2F(TString::Format("gammaGammaSub%i", angleIndex), Form("%.1f deg #gamma-#gamma, time-random-bg subtracted", fAngleCombinations[angleIndex]), gbin, gLow, gHigh, gbin, gLow, gHigh);
					myhist->Sumw2(); // setting so errors are properly calculated
					gammaGammaSubList.AddAtAndExpand(myhist, angleIndex);
				} // !myhist

				// Filling histogram
				if (ggTime < ggHigh)
				{
					myhist->Fill(energy_vec.at(g1), energy_vec.at(g2));
					sum_hist->Fill(energy_vec.at(g1), energy_vec.at(g2));
					// dT_coin->Fill(ggTime);
					// myhist->Fill(energy_vec.at(g2), energy_vec.at(g1));
				}
				else if (bgLow < ggTime && ggTime < bgHigh)
				{
					myhist->Fill(energy_vec.at(g1), energy_vec.at(g2), -ggHigh / (bgHigh - bgLow));
					sum_hist->Fill(energy_vec.at(g1), energy_vec.at(g2), -ggHigh / (bgHigh - bgLow));
					// myhist->Fill(energy_vec.at(g2), energy_vec.at(g1), -ggHigh/(bgHigh-bgLow));
				}
			} // grif2

			// EVENT MIXED MATRICES
			// event mixing, we use the last event as second griffin
			checkMix = (int)last_grif_energy.size();
			if (checkMix < event_mixing_depth)
				continue;
			for (auto lg = 0; lg < (checkMix - 1); ++lg)
			{
				unsigned int multLG = last_grif_energy.at(lg).size();

				for (unsigned int g3 = 0; g3 < multLG; ++g3)
				{
					double angle = pos_vec.at(g1).Angle(last_grif_position.at(lg).at(g3)) * 180. / TMath::Pi();
					if (angle < 0.0001)
						continue;
					int angleIndex = GetAngleIndex(angle, fAngleCombinations);

					// Generating/Retrieving histograms
					TH2F *myhist = ((TH2F *)0);
					if (angleIndex < gammaGammaMixedList.GetSize())
						myhist = ((TH2F *)(gammaGammaMixedList.At(angleIndex)));
					if (!myhist)
					{
						myhist = new TH2F(TString::Format("gammaGammaMixed%i", angleIndex), Form("%.1f deg #gamma-#gamma, event-mixed", fAngleCombinations[angleIndex]), gbin, gLow, gHigh, gbin, gLow, gHigh);
						myhist->Sumw2(); // setting so errors are properly calculated
						gammaGammaMixedList.AddAtAndExpand(myhist, angleIndex);
					} // !myhist

					// Filling histogram
					myhist->Fill(energy_vec.at(g1), last_grif_energy.at(lg).at(g3));
					sum_hist_mixed->Fill(energy_vec.at(g1), last_grif_energy.at(lg).at(g3));
				} // end g3
			}	  // end LG

		} // grif_hit

		if (i % 10000 == 0)
		{
			progress_bar.display();
		}
		++progress_bar; // iterates progress_bar

		// update "last" event
		last_grif_energy.push_back(energy_vec);
		last_grif_position.push_back(pos_vec);
		lgsize = static_cast<int>(last_grif_energy.size());
		if (lgsize > event_mixing_depth)
		{
			last_grif_energy.erase(last_grif_energy.begin());
			last_grif_position.erase(last_grif_position.begin());
		}

		// cleaning up for next event
		energy_vec.clear();
		pos_vec.clear();
		time_vec.clear();
		// detector_vec.clear();
	} // end fill loop

	progress_bar.done();

	// Writing histograms to file
	TFile *out_file = new TFile(Form("gg_%i_histograms.root", run_number), "RECREATE");
	std::cout << "Writing output file: " << out_file->GetName() << std::endl;

	out_file->cd();

	TDirectory *dir_TRS = out_file->mkdir("TimeRandomSubtracted");
	dir_TRS->cd();
	gammaGammaSubList.Compress();
	gammaGammaSubList.Write();
	TDirectory *dir_Mixed = out_file->mkdir("EventMixed");
	dir_Mixed->cd();
	gammaGammaMixedList.Compress();
	gammaGammaMixedList.Write();
	TDirectory *sum_dir = out_file->mkdir("SumHistograms");
	sum_dir->cd();
	sum_hist->Write();
	sum_hist_mixed->Write();

	out_file->Write();
	delete out_file;

	return 0;
} // ProcessData

///******************************************************************************
// * Returns the angular index
// *
// * @param angle The angle between two gammas
// * @param vec Vector of angles
// *****************************************************************************/
int GetAngleIndex(double angle, std::vector<double> vec)
{

	// corner cases
	if (angle <= vec.front())
	{
		return 0;
	}
	if (angle >= vec.back() - 1.)
	{
		return vec.size() - 1;
	}

	// binary search
	unsigned int i = 0, j = vec.size(), mid = 0;
	while (i < j)
	{
		mid = (i + j) / 2;

		if (vec[mid] == angle)
			return vec[mid];

		// searching left half
		if (angle < vec[mid])
		{
			// if angle is greater than previous to mid, return closest of two
			if (mid > 0 && angle > vec[mid - 1])
			{
				return GetClosest(mid - 1, mid, fAngleCombinations, angle);
			}

			// repeat for left half
			j = mid;
		}
		// if angle is greater than mid
		else
		{
			if (mid < vec.size() - 1 && angle < vec[mid + 1])
			{
				return GetClosest(mid, mid + 1, fAngleCombinations, angle);
			}

			// update i
			i = mid + 1;
		}
	}
	// Only single element left after search
	return mid;
} // GetAngleIndex

///******************************************************************************
// * Returns the value closest to the target
// * Assumes val2 is greater than val1 and target lies inbetween the two
// *
// * @param val1 First value to compare
// * @param val2 Second value to compare
// * @param vec Vector of values
// * @param target Target value
// *****************************************************************************/
int GetClosest(int val1, int val2, std::vector<double> vec, double target)
{
	if ((target - vec[val1]) >= (vec[val2] - target))
		return val2;
	else
		return val1;
} // GetClosest

/******************************************************************************
 * Detects type of input file
 *
 *****************************************************************************/
void AutoFileDetect(std::string fileName)
{
	size_t dot_pos = fileName.find_last_of('.');
	std::string ext = fileName.substr(dot_pos + 1);

	if (ext == "root")
	{
		OpenRootFile(fileName);
	}
	else if (ext == "cal")
	{
		notifier->AddCalFile(fileName);
	}
	else
	{
		std::cerr << "Discarding unknown file: " << fileName.c_str() << std::endl;
	}
} // End AutoFileDetect

/************************************************************/ /**
																* Opens Root files
																*
																* @param dir_name   Directory name
																* @param ext        Extension of the files (default = ".root")
																***************************************************************/
void OpenRootFile(std::string fileName)
{
	TFile f(fileName.c_str());
	if (f.Get("AnalysisTree"))
	{
		if (!gChain)
		{
			gChain = new TChain("AnalysisTree");
			notifier->AddChain(gChain);
			gChain->SetNotify(notifier);
		}
		gChain->Add(fileName.c_str());
		std::cout << "Added: " << fileName << std::endl;
	}
} // end OpenRootFile

/******************************************************************************
 * Prints usage message and version
 *****************************************************************************/
void PrintUsage(char *argv[])
{
	std::cerr << argv[0] << "\n"
			  << "usage: " << argv[0] << " calibration_file analysis_tree [analysis_tree_2 ... ]\n"
			  << " calibration_file: calibration file (must end with .cal)\n"
			  << " analysis_tree:    analysis tree to convert (must end with .root)"
			  << std::endl;
} // end PrintUsage
