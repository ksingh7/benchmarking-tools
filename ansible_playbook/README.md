yum update -y
yum install -y python-pip git python-devel
pip install --upgrade pip
pip install ansible
pip install python-novaclient
pip install python-clinderclient
pip install shade

Gather results using the below playbook
Supply run variable 

ansible-playbook -i inventory/hosts gather_results.yml --extra-vars "run=run1"

Once output is collected in results/results_(tool name) directory
merge your output
for i in read write readwrite randread randwrite ; do cat *_$i.summary >> $i.summary ; done
for i in read write randread randwrite; do cat $i.summary >> final_result.summary; done
cp readwrite.summary final_result_readwrite.summary
