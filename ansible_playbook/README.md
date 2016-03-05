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
