# You have previously run sNMF (see 01_Run_sNMF.sh) and obtained the Q matrices for each run and each K.

# Define which run had the least entropy and the number of ancestral populations, K
min_entropy=$(grep "Cross-Entropy (masked data):" crossEntropy_run*_K*.log | cut -f2 | sort | head -n1)
myfile=$(grep ${min_entropy} crossEntropy_run*_K*.log | cut -d: -f1)
myrun=$(basename ${myfile} | cut -d "_" -f2)
echo -e 'K\tCross_Entropy' >K_vs_CrossEntropy.txt

for mylist in $(ls crossEntropy_${myrun}_K*.log);
do
    myK=$(basename $(basename ${mylist} | cut -d"K" -f2) .log);
    myvalue=$(grep "Cross-Entropy (masked data):" ${mylist} | cut -f2);
    echo -e ${myK}'\t'${myvalue} >>K_vs_CrossEntropy.txt;
done

myK=$(grep ${min_entropy} K_vs_CrossEntropy.txt | cut -d" " -f1)
echo "The number of ancestral populations (K) is" ${myK}
myrun_number=${myrun/"run"/""}
echo "The run with the least cross-entropy is " ${myrun_number}

grep "Cross-Entropy (masked data):" crossEntropy_run${myrun_number}_K*.log
