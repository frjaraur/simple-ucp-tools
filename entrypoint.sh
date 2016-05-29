#!/bin/bash

Help(){
	echo -e "\n\nSimple UCP-Tools Usage"
	echo -e "\n\t docker run --rm --name simple-ucp-tools -v <YOUR_OUTPUT_DIR>:/OUTDIR simple-ucp-tools <OPTION>"
	echo -e "\n\t OPTIONS:\n\t\t-h This Help\n\t\t-n UCP_URL_WITH_PORT/DTR_URL_WITH_PORT (if not default 443 port)\n\t\t-u UCP_USERNAME (defaults to 'admin')\n\t\t-p USP_PASSWORD (defaults to 'orca')\n\t\t-c Downloads UCP CA as ucp-ca.pem\n\t\t-d Downloads DTR CA as <DTR>.crt"
	echo -e " \n\nWhen using for DTR CA download you must move <DTR>.crt file to trusted system certs and them update them using system commands."
	echo -e "\n\n"
	exit 0
}

GetBundle(){

	AUTHTOKEN=$(curl -sk -d "{\"username\":\"${ucp_username}\",\"password\":\"${ucp_password}\"}" ${ucp_url}/auth/login | jq -r .auth_token)
	curl -sk -H "Authorization: Bearer $AUTHTOKEN" ${ucp_url}/api/clientbundle -o bundle.zip >/dev/null 2>&1
	unzip  -qqo bundle.zip 2>/dev/null
	rm bundle.zip
	exit 0
}

GetCA(){
	curl -sk ${ucp_url}/ca > ucp-ca.pem
	exit 0
}

GetDTRCA(){
	dtr_port="$(echo $ucp_url|sed -e "s/https\:\/\///g")"
	dtr="$(echo ${dtr_port}|cut -d ':' -f1)"
	openssl s_client -connect ${dtr_port} -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM >${dtr}.crt
	exit 0
}


#DEFAULTS:
ucp_username="admin"
ucp_password="orca"
getca=0
getdtrca=0
 
while getopts "hu:p:n:cd" opt; do
  case $opt in
    h)
      Help
      ;;
    c)
      getca=1
      ;;
    d)
      getdtrca=1
      ;;      
    n)
      ucp_url=$OPTARG
      ;;
    u)
      ucp_username=$OPTARG
      ;;
    p)
      ucp_password=$OPTARG
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    *)
      echo "Invalid option" >&2
      exit 1
      ;;
  esac
done

[ ! -n "${ucp_url}" ] && echo "At least UCP Fully Qualified Name is Required !!!!" && exit 1

[ ${getca} -eq 1 -a ${getdtrca} -eq 1 ] && echo "It is not possible to have DTR and UCP on same host/port ..." && exit 1

[ ${getca} -eq 1 ] && GetCA

echo "UCP $ucp_url"
[ ${getdtrca} -eq 1 ] && GetDTRCA

echo -e "\nUCP URL:\t$ucp_url"
echo -e "\nUCP USERNAME:\t$ucp_username"
echo -e "\nUCP PASSWORD:\t$ucp_password"

GetBundle
