#!/bin/bash

function change-realm() {  eval $( $OWL/bin/owl change-realm $@ ) ; };
function aws-login() {  eval $( $OWL/bin/owl aws-login "$@" ) ; };

# aws-login --account dev-twilio
# aws-ec2 --ssm --role messaging-ratequeue-master --account dev-twilio --dev-us1 --sid HOaf9ecd82e5c403807f780b03f180a3a8

COLOR_BLACK="\e[30m"
COLOR_RED="\e[31m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_BLUE="\e[34m"
COLOR_MAGENTA="\e[35m"
COLOR_CYAN="\e[36m"
COLOR_WHITE="\e[37m"
COLOR_RESET="\e[0m"

function aws-world-selector() {
	echo "Select World"
  echo "1. classic"
  echo "2. messaging"
  read "worldvar?Input Selection: "
  if [[ "$worldvar" =~ ^[12]$ ]]; then
  	return $worldvar
  else
    return 0
  fi
}

function aws-env-selector() {
	worldprefix=$1
	echo "Select Environment"
  echo "1. dev"
  echo "2. stage"
  echo "3. prod"
  read "envvar?Input Selection: "
  if [[ "$envvar" =~ ^[123]$ ]]; then
  	return $envvar
  else
    return 0
  fi
}

function aws-realm-selector() {
	envprefix=$1
  echo "Select Realm"
  echo "1. ${envprefix}us1"
  echo "2. ${envprefix}ie1"
  # echo "3. ${envprefix}au1"
  read "realmvar?Input Selection: "
  if [[ "$realmvar" =~ ^[123]$ ]]; then
  	return $realmvar
  else
    return 0
  fi
}

function role-selector() {
  echo "Select Role"
  echo "1. messaging-ratequeue-master"
  echo "2. messaging-ratequeue-slave"
  echo "3. sms-ratequeue-accounts-primary"
  echo "4. sms-ratequeue-accounts-replica"
  read "rolevar?Input Selection: "
  if [[ "$rolevar" =~ ^[1234]$ ]]; then
  	return $rolevar
  else
    return 0
  fi
}


function aws-new-ec2() {
	sid=$1
	if [[ -z $sid ]]; then
		echo "Ussage: aws-new-ec2 <sid>"
		return
	fi
  worlds=("" "messaging-")
  envs=("dev-" "stage-" "")
  realms=("us1" "ie1" "au1")
  roles=("messaging-ratequeue-master" "messaging-ratequeue-slave" "sms-ratequeue-accounts-primary" "sms-ratequeue-accounts-replica")

	aws-world-selector
  worldindex=$?
  if [[ $worldindex -eq 0 ]]; then
  	echo "Wrong Selection"
  	return 1
  fi
  worldprefix=${worlds[worldindex]}

  aws-env-selector $worldprefix
  envindex=$?
  if [[ $envindex -eq 0 ]]; then
  	echo "Wrong Selection"
  	return 1
  fi
  envprefix=${envs[envindex]}

  aws-realm-selector $envprefix
  realmindex=$?
  if [[ $realmindex -eq 0 ]]; then
  	echo "Wrong Selection"
  	return 1
  fi
  realmprefix=${realms[realmindex]}

  if [[ $worldprefix$envprefix != "" && $envprefix == "" ]]; then
  	envprefix="prod-"
  fi

  role-selector
  roleindex=$?
  if [[ $roleindex -eq 0 ]]; then
  	echo "Wrong Selection"
  	return 1
  fi
  role=${roles[roleindex]}

  if [[ $envindex -eq 3 ]]; then
  	read "reason?Please input a reason: "
  	if [[ $reason == "" ]]; then
  		echo "Reason must be valid"
  		return 1
  	fi
  	reasoncmd="--reason '${reason}'"
  else
  	reasoncmd=""
  fi

  realm=$envprefix$realmprefix
  account="${worldprefix}${envprefix}twilio"

  echo -e "${COLOR_WHITE} Login into aws account ${COLOR_GREEN} ${account} ${COLOR_WHITE}. Using: ${COLOR_RESET}"
  echo "aws-login --account ${account}"
	aws-login --account ${account}
	echo -e "${COLOR_YELLOW} command for ec2 connect: ${COLOR_RESET}"
	echo "aws-ec2 --ssm --role ${role} --account ${account} --${realm} --sid ${sid} ${reasoncmd}"
}

function aws-ec2() {
  LINES=${LINES} COLUMNS=${COLUMNS} ${OWL}/command/pellets/ec2/scripts/login-wrapper "${@}"
}
