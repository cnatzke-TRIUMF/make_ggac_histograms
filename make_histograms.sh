#!/bin/bash

# -----------------------------
# functions
# -----------------------------
function unpack_data(){

    for file in $analysis_dir/analysis_????.root;
    do
        basename=${file##*/}
        filename=${basename%.*}
        run_number=${filename##*_}
        histogram_file=$histogram_dir/gg_${run_number}.root
    
        if [ -f $histogram_file ]; then
            echo "File $histogram_file  already exist, skipping ..."
        elif [ ! -f $histogram_file ]; then
            echo "$sort_code $cal_file $file"
            echo "mv gg_* $HISTDIR/gg_$1_$BATCH_COUNTER.root"
        elif [ $histogram_file -ot $sort_code ] || [ $histogram_file -ot $file ];
            echo "$sort_code $cal_file $file"
            echo "mv gg_* $HISTDIR/gg_$1_$BATCH_COUNTER.root"
        fi
        if [ -f $HFILE ]
        then
        # if the sort code gets updated or the analysis tree is updated
            if [ $HFILE -ot $SORTCODE ] || [ $HFILE -ot $file ];
            then
                echo "Sort code or analysis tree have changed, rerunning sort"
                echo "$SORTCODE $FILE_BATCH $CALFILE"
                echo "mv gg_* $HISTDIR/gg_$1_$BATCH_COUNTER.root"
            fi
        fi
    done


    for file in $DATA_DIR/analysis"$1"_*.root; do
        fullname=${file##*/}
        filename=${fullname%%.*}
        subrun=${filename##*_}
        hist_file=$HIST_DIR/run_$1_$subrun.root
        if [[ ! -f $hist_file ]]; then
             # echo "$SORT_CODE $cal_file $file"
             cd $SORT_DIR
             $SORT_CODE $CAL_FILE $file
             mv histograms.root $hist_file
        elif [[ -f $hist_file ]]; then
            echo "Run $1 subrun $subrun histograms already exist, skipping ..."
        fi
    done
}

# -----------------------------
# Main
# -----------------------------

if [ $# -ne 2 ] 
then
   echo "make_histograms.sh element isotope"
   exit
fi

element=$1
isotope=$2
parent_dir="/data_fast/cnatzke/osg_output/two-photon-griffin/z${element}.a${isotope}"
analysis_dir="$parent_dir/analysis-trees"
histogram_dir="$parent_dir/histograms"
cal_file="$parent_dir/calibration.cal"
sort_code="~/projects/two-photon-decay/simulations/ggac/bin/make_histograms.sh"
sort_dir="~/projects/two-photon-decay/simulations/ggac/ongoing-sort"

echo "Making GGAC histograms for"
echo "  element: $element"
echo "  isotope: $isotope"
echo

unpack_data()

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

#================================
# for a single run
#if [ $# -eq 1 ]
#then
#    file=$ANALDIR/analysis"$1"_*.root;
#    g=${file:DLEN+9}
#    h=${g:0:${#g}-6}
#    i=${g:0:${#g}-7} # run number
#
#      RUNFILES=$ANALDIR/analysis${i}_"*".root
#      HFILE=$HISTDIR/gg_${i}.root
#
#      if [ $i -gt $m ] && [ $n -gt $i ];
#      then
#         if [ ! -f $HFILE ];
#         then
#           # echo "$SORTCODE $RUNFILES $CALFILE"
#           # echo "mv gg_* $HISTDIR/"
#           $SORTCODE $RUNFILES $CALFILE
#           mv gg_* $HISTDIR/gg_${i}_total.root
#
#         fi
#         if [ -f $HFILE ]
#         then
#            # if the sort code gets updated or the analysis tree is updated
#            if [ $HFILE -ot $SORTCODE ] || [ $HFILE -ot $f ];
#            then
#               echo "Sort code or analysis tree have changed, rerunning sort"
#                echo "$SORTCODE $RUNFILES $CALFILE"
#                echo "mv gg_* $HISTDIR/"
#               #$SORTCODE $RUNFILES $SELECTOR --max-workers=4
#               #mv TwoPhotonGriffinAnglePlots* $HISTDIR/
#            fi
#         fi
#     elif [[ $i < $m ]]; then
#         echo "Run $1 is less than the low run cutoff: $m"
#         echo "Exiting ..."
#     else
#         echo "$1 is non accepted run format"
#         echo "Exiting ..."
#      fi
#fi
#
#
#if [ $# -eq 2 ]; # Run Number, Batch size
#then
#    for run in `seq $1 $2` ; do
#            # check for bad runs
#            case `grep -Fx "$run" "$bad_run_list" >/dev/null; echo $?` in
#                0)
#                # if found
#                continue
#                ;;
#                1)
#                # check if run exists
#                if [[ "$(ls $HISTDIR/gg_${run}_* | wc -l)" -ge "1" ]]; then
#                    echo "gg_${run}_total.gg already exists!"
#                    continue
#                else
#                    # if not found
#                    file=$ANALDIR/analysis"$run"_*.root;
#                    g=${file:DLEN+9}
#                    h=${g:0:${#g}-6}
#                    i=${g:0:${#g}-7} # run number
#
#                    RUNFILES=$ANALDIR/analysis${i}_"*".root
#                    HFILE=$HISTDIR/gg_${i}.root
#
#                    if [ $i -gt $m ] && [ $n -gt $i ];
#                    then
#                        #echo "$SORTCODE $RUNFILES $CALFILE"
#                        #echo "mv gg_${run}_* $HISTDIR/"
#                        $SORTCODE $RUNFILES $CALFILE
#                        mv gg_* $HISTDIR/gg_${i}_total.root
#                    elif [[ $i < $m ]]; then
#                        echo "Run $1 is less than the low run cutoff: $m"
#                        echo "Exiting ..."
#                        exit
#                    else
#                        echo "$1 is non accepted run format"
#                        echo "Exiting ..."
#                        exit
#                    fi
#                fi
#                ;;
#                *)
#                # error
#                echo "Error encountered in bad run file."
#                exit
#                ;;
#        esac
#    done
#fi

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
