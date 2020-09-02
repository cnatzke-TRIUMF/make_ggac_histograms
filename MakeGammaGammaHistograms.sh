#!/bin/bash

ANALDIR=/tig/hagodon_data2/S2036/AnalysisTrees
HISTDIR=/tig/hagodon_data2/S2036/AngularCorrelations/Histograms
DLEN=${#ANALDIR}
SORTCODE=/tig/hagodon_data2/S2036/AngularCorrelations/MakeGammaGammaHistograms/myBuild/GammaGammaHistograms
CALFILE=/tig/hagodon_data2/S2036/CalibrationFiles/CalibrationFile.cal  # Calibration File
bad_run_list=/tig/hagodon_data2/S2036/bad_runs.dat

m=15600 #Only Sort after this run First good run: 52042
n=99999 #Only Sort until this run

#############################################
# Main
#############################################

if [ $# -eq 0 ] || [[ $# > 2 ]]
then
   echo "Pass 1 or 2 arguments"
   echo "1: $0 run_number"
   echo "   Process all subruns in run_number"
   echo "2: $0 run_number_1 run_number_2"
   echo "   Process all subruns between run_number_1 and run_number_2"
fi

# for a single run
if [ $# -eq 1 ]
then
    file=$ANALDIR/analysis"$1"_*.root;
    g=${file:DLEN+9}
    h=${g:0:${#g}-6}
    i=${g:0:${#g}-7} # run number

      RUNFILES=$ANALDIR/analysis${i}_"*".root
      HFILE=$HISTDIR/gg_${i}.root

      if [ $i -gt $m ] && [ $n -gt $i ];
      then
         if [ ! -f $HFILE ];
         then
           # echo "$SORTCODE $RUNFILES $CALFILE"
           # echo "mv gg_* $HISTDIR/"
           $SORTCODE $RUNFILES $CALFILE
           mv gg_* $HISTDIR/gg_${i}_total.root

         fi
         if [ -f $HFILE ]
         then
            # if the sort code gets updated or the analysis tree is updated
            if [ $HFILE -ot $SORTCODE ] || [ $HFILE -ot $f ];
            then
               echo "Sort code or analysis tree have changed, rerunning sort"
                echo "$SORTCODE $RUNFILES $CALFILE"
                echo "mv gg_* $HISTDIR/"
               #$SORTCODE $RUNFILES $SELECTOR --max-workers=4
               #mv TwoPhotonGriffinAnglePlots* $HISTDIR/
            fi
         fi
     elif [[ $i < $m ]]; then
         echo "Run $1 is less than the low run cutoff: $m"
         echo "Exiting ..."
     else
         echo "$1 is non accepted run format"
         echo "Exiting ..."
      fi
fi


if [ $# -eq 2 ]; # Run Number, Batch size
then
    for run in `seq $1 $2` ; do
            # check for bad runs
            case `grep -Fx "$run" "$bad_run_list" >/dev/null; echo $?` in
                0)
                # if found
                continue
                ;;
                1)
                # check if run exists
                if [[ "$(ls $HISTDIR/gg_${run}_* | wc -l)" -ge "1" ]]; then
                    echo "gg_${run}_total.gg already exists!"
                    continue
                else
                    # if not found
                    file=$ANALDIR/analysis"$run"_*.root;
                    g=${file:DLEN+9}
                    h=${g:0:${#g}-6}
                    i=${g:0:${#g}-7} # run number

                    RUNFILES=$ANALDIR/analysis${i}_"*".root
                    HFILE=$HISTDIR/gg_${i}.root

                    if [ $i -gt $m ] && [ $n -gt $i ];
                    then
                        #echo "$SORTCODE $RUNFILES $CALFILE"
                        #echo "mv gg_${run}_* $HISTDIR/"
                        $SORTCODE $RUNFILES $CALFILE
                        mv gg_* $HISTDIR/gg_${i}_total.root
                    elif [[ $i < $m ]]; then
                        echo "Run $1 is less than the low run cutoff: $m"
                        echo "Exiting ..."
                        exit
                    else
                        echo "$1 is non accepted run format"
                        echo "Exiting ..."
                        exit
                    fi
                fi
                ;;
                *)
                # error
                echo "Error encountered in bad run file."
                exit
                ;;
        esac
    done
fi

# for a range of subruns
#if [ $# -eq 2 ] # Run Number, Batch size
#then
#    declare -a FILE_BATCH
#    declare -a FILE_LIST
#    FILE_ITER=1
#    BATCH_COUNTER=0
#
#    RUNFILES=$ANALDIR/analysis${i}_"*".root
#    HFILE=$HISTDIR/gg_${i}.root
#
#    FILE_LIST=$(find ${ANALDIR}/ -name analysis"$1"_???.root | sort)
#    NUM_FOUND=$(find ${ANALDIR}/ -name analysis"$1"_???.root | wc -l)
#    TOTAL_BATCHES=$((NUM_FOUND / $2 + 1))
#    echo "Found ${NUM_FOUND} Files"
#    echo "Requires ${TOTAL_BATCHES} Batches"
#
#    for file in $FILE_LIST;
#    do
#
#        FILE_BATCH=("${FILE_BATCH[@]}" "$file")
#
#        # Process files in specified batch sizes
#        if (( $FILE_ITER % $2 == 0 ))
#        then
#            #echo "Files: ${FILE_BATCH[@]}"
#
#            if [ $1 -gt $m ] && [ $n -gt $1 ];
#            then
#                if [ ! -f $HFILE ];
#                then
#                    #echo "$SORTCODE ${FILE_BATCH[@]} $CALFILE"
#                    #echo "mv gg_* $HISTDIR/gg_$1_$BATCH_COUNTER.root"
#                    $SORTCODE ${FILE_BATCH[@]} $CALFILE
#                    mv gg_* $HISTDIR/gg_${1}_${BATCH_COUNTER}.root
#                fi
#                if [ -f $HFILE ]
#                then
#                   # if the sort code gets updated or the analysis tree is updated
#                    if [ $HFILE -ot $SORTCODE ] || [ $HFILE -ot $file ];
#                    then
#                        echo "Sort code or analysis tree have changed, rerunning sort"
#                        echo "$SORTCODE $FILE_BATCH $CALFILE"
#                        echo "mv gg_* $HISTDIR/gg_$1_$BATCH_COUNTER.root"
#                    fi
#                fi
#            fi
#
#            unset FILE_BATCH
#            BATCH_COUNTER=$((BATCH_COUNTER + 1))
#        fi
#
#        # Process remaining files
#        if (( $BATCH_COUNTER == $((TOTAL_BATCHES - 1))  && (( $FILE_ITER == $NUM_FOUND)) ))
#        then
#            echo "Files: ${FILE_BATCH[@]}"
#            if [ $1 -gt $m ] && [ $n -gt $1 ];
#            then
#                if [ ! -f $HFILE ];
#                then
#                    #echo "$SORTCODE ${FILE_BATCH[@]} $CALFILE"
#                    #echo "mv gg_* $HISTDIR/gg_$1_$BATCH_COUNTER.root"
#                    $SORTCODE ${FILE_BATCH[@]} $CALFILE
#                    mv gg_* $HISTDIR/gg_${i}_total.root
#                fi
#                if [ -f $HFILE ]
#                then
#                   # if the sort code gets updated or the analysis tree is updated
#                    if [ $HFILE -ot $SORTCODE ] || [ $HFILE -ot $file ];
#                    then
#                        echo "Sort code or analysis tree have changed, rerunning sort"
#                        echo "$SORTCODE $FILE_BATCH $CALFILE"
#                        echo "mv gg_* $HISTDIR/gg_$1_$BATCH_COUNTER.root"
#                    fi
#                fi
#            fi
#
#            unset FILE_BATCH
#        fi
#
#        FILE_ITER=$((FILE_ITER + 1))
#
#    done
#fi
