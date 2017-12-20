
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
     
     sh fifastlboyz_T_generator.sh $(($div_n - 1)) "${group1[@]}" 
     sh fifastlboyz_T_generator.sh $(($div_n - 1)) "${arr[@]}"
 
  else
     echo ""
     echo "Hmm! Something feels ODD here!"
     echo "Group 1 with less players will play additional match with one randonly assigned opponent from Group 1"
     echo ""
     sh fifastlboyz_T_generator.sh $(($div_n)) "${arr[@]}"

     sh fifastlboyz_T_generator.sh $(($div_n - 1)) "${group1[@]}"

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
          sh fifastlboyz_T_generator.sh $m_limit "${local_arr[@]}"
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


