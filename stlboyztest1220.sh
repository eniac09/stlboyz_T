
usage()
{
echo "#######################################################################################"
echo "# FIFASTLBOYZ Tournament random matchup script"
echo "# usage - sh <Script_Name> "
echo "# Follow on screen steps "
echo "# You will get groups and matches on screen"
echo "# "
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

matchup_main()
{
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
logs_f="fifastlboyz_T_matchups.log"

> $schedule
#echo `date` > $logs_f
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

}

check_matches_quota()
{
   local retVal_cmq="true"

   mq=`cat matches.confirmed | grep $1 | wc -l`
   if [ $mq -lt $match_quota ];then
     retVal_cmq="false"
   fi
 
   echo $retVal_cmq
}


echo "Random players selected -" $PN1 $PN2
match_quota=3
#isValidSelect=`check_matches_quota Amit`

#echo $isValidSelect

echo "Hello, enter no of players: "
 read no_of_p


args_p=0

for (( pc=0; pc< $no_of_p; pc++ ))
do
 args_p=$(($pc + 1))

 echo "enter player"$args_p "name" 
 read local_arr[$pc] 
done

echo ""
echo ""
echo "Players list confirmed : ${local_arr[@]}"


group_maker()
{
  arr=("${local_arr[@]}")
  #echo ${arr[@]}
  group1=""
  group2=""
  rem_n=`expr $1 % 2`
  div_n=`expr $1 / 2`
  
  random_div=$1
 
  for (( c=0; c< $div_n; c++ ))
  do
     P=$[ $RANDOM % $random_div ]
     #echo  "Random nuber is  -$P"
     #echo "Random Player is  ${arr[$P]}"
     group1=(${group1[@]} ${arr[$P]})
     arr=(${arr[@]:0:$P} ${arr[@]:$(($P + 1))})

     #echo "Group 1 current - ${group1[@]}"
     #echo "Remaining player -  ${arr[@]}"

     random_div=$(( $random_div - 1))
  done 

 echo "Group 1  - ${group1[@]}"
 echo "Group 2  - ${arr[@]}"



  if [ $rem_n -eq 0 ];then
     echo ""
     echo "Even Stevens! Easy Peasey!"   
     echo ""
     
     sh matchup_main $(($div_n - 1)) "${group1[@]}" 
     sh matchup_main $(($div_n - 1)) "${arr[@]}"
 
  else
     echo ""
     echo "Hmm! Something feels ODD here!"
     echo "Group 1 with less players will play additional match with one randonly assigned opponent from Group 1"
     echo ""
     sh matchup_main $(($div_n)) "${arr[@]}"

     sh matchup_main $(($div_n - 1)) "${group1[@]}"

     echo ""
     echo ""

     T1=("${group1[@]}")
     T2=("${arr[@]}")

     R2R=$(($div_n + 1 ))
     R1R=$(($div_n  ))


     for (( c=0; c< $div_n; c++ ))
     do
        R1=$[ $RANDOM % $R1R ] 
        R2=$[ $RANDOM % $R2R ]

        echo "Random Matchup $(($c +1 )) is  ${T1[$R1]} vs ${T2[$R2]}"
           
	T1=(${T1[@]:0:$R1} ${T1[@]:$(($R1 + 1))})
        T2=(${T2[@]:0:$R2} ${T2[@]:$(($R2 + 1))})
       
        R1R=$(($R1R - 1 ))
        R2R=$(($R2R - 1 ))

        if [ $R1R -lt 1 ];then
           exit;
        fi
     done   
  fi

}

get_t_type()
{
echo "Select tournament type RoundRobin(1) or Groups(2)"
read t_type

while true
do
  case $t_type in
   [1]* ) echo "Okay, Round Robin it is!"
          echo "Give me matches per players. Remember number of matches can not be equal or more than players count"
          read m_limit
          echo ""
          sh matchup_main $m_limit "${local_arr[@]}"
           break;;

   [2]* ) echo "Okay, Bringing on Group of Death formula!"
          echo "No. of players - $no_of_p"
          if [ $no_of_p -lt 6 ];then
             echo "Groups no fun with less than 6 players. Run again with Round Robin"
          else
             group_maker $no_of_p   
          fi
	  break;;

   * )     echo "Dude, just enter 1 or 2, please."; get_t_type;break; 
  esac
done
}

get_t_type
