#!/bin/bash
usage()
{
echo "#######################################################################################"
echo "# FIFASTLBOYZ Tournament random matchup script"
echo "# usage - sh fifastlboyz_T_generator.sh 5 Amit Debu Dev Nishant Sujeet Jitesh Antony Puru"
echo "# "\$"1 - number of matches per player"
echo "# "\$"2-"\$"n - players names"
echo "# *** ("\$"1 always less than count of players  "\$"2-"\$"n)"
echo "#######################################################################################"
}
check_matches_quota()
{
   local retVal_cmq=""

   mq=`cat $schedule | grep $1 | wc -l`
   if [ $mq -lt $match_quota ];then
     retVal_cmq="true"
   else
     retVal_cmq="false"
   fi
   echo $retVal_cmq
}

check_matchup_status()
{
   local retVal_cms=""

   ms=`cat $schedule | grep $1 | grep $2 | wc -l`
   if [ $ms -lt 1 ];then
     retVal_cms="true"
   else
     retVal_cms="false"
   fi
   echo $retVal_cms
}


get_random_players(){

arr_l=${#arr[@]}
if [ $arr_l -gt 1 ];then

   P1=$[ $RANDOM % $(($args_p -1)) ]
   P2=$[ $RANDOM % $(($args_p -1)) ]

   PN1=${arr[$P1]}
   PN2=${arr[$P2]}

   if [ "$PN1" != "$PN2" ];then
      echo "Random players selected -" $PN1 $PN2 >> $logs_f
	   isValidSelect1=`check_matches_quota $PN1`
           isValidSelect2=`check_matches_quota $PN2`

	   if [ "$isValidSelect1" == "false" ];then
   	         arr=(${arr[@]:0:$P1} ${arr[@]:$(($P1 + 1))})
	         echo "$PN1 has already have $match_limit matches. Removed from next iteration" >> $logs_f
	         args_p=$(($args_p - 1))
                 if [ "${#arr[@]}" -lt 2 ]; then
                     echo "End of iterations. All matched or exit condition reached." >> $logs_f
                     break;
                 fi     
                 if [ "$isValidSelect2" == "false" ];then
	            arr=(${arr[@]:0:$P2} ${arr[@]:$(($P2 + 1))})
        	    echo "$PN2 has already have $match_limit matches. Removed from next iteration" >> $logs_f
	            args_p=$(($args_p - 1))
                    if [ "${#arr[@]}" -lt 2 ]; then
                       echo "End of iterations. All matched or exit condition reached"  >> $logs_f
                       break;
                    fi
	         fi
	   else   
                 if [ "$isValidSelect2" == "false" ];then
                    arr=(${arr[@]:0:$P2} ${arr[@]:$(($P2 + 1))})
                    echo "$PN2 has already have $match_limit matches. Removed from next iteration" >> $logs_f
                    args_p=$(($args_p - 1))
                    if [ "${#arr[@]}" -lt 2 ]; then
                       echo "End of iterations. All matched or exit condition reached" >> $logs_f
                       break;
                    fi 
                 else
		   isValidMatchUp=`check_matchup_status $PN1 $PN2`
		   if [ "$isValidMatchUp" == "false" ];then
		      echo "** no match ** $PN1 x $PN2 already matched" >> $logs_f
            	   else
	        	echo "match set $PN1 x $PN2" >> $logs_f
		        echo "$PN1 vs $PN2" >> $schedule
                        echo "$PN1 vs $PN2" >> $logs_f
		        echo "" >> $logs_f
	           fi
                fi 
	   fi
    fi
   get_random_players	
fi
}


args_p=0
arr=""
for i in "$@"
do
 args_p=$(($args_p + 1))
 if [ $args_p -gt 1 ]; then
     arr=(${arr[@]} "$i")
 fi
done
t_m=$(($args_p -1))

if [ $t_m -le $1 ]; then
   echo "number of matches can not be equal or more than players count"
   usage
   exit 0
fi

schedule="matches.confirmed_temp"
schedule_f="fastlboyz_T_matches.confirmed_"`date +"%m%d%y_%H%M"`
logs_f="fifastlboyz_T_matchups.log"`date +"%m%d%y_%H%M"`

> $schedule
echo `date` > $logs_f
echo "" >> $logs_f

match_quota=$1
players=("${arr[@]}")
#echo "${players[@]}"

match_limit=$1
get_random_players


echo `date` > $schedule_f
echo "" >> $schedule_f
echo "Players count - $t_m  ${players[@]} " >> $schedule_f
echo "matches per player - $1 " >>  $schedule_f
echo "" >> $schedule_f
cat $schedule >> $schedule_f

cat $schedule_f
rm $schedule $schedule_f



