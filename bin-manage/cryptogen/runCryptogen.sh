#!/usr/bin/env bash
CURRENT="$(dirname $(readlink -f ${BASH_SOURCE}))"
CRYPTO_CONFIG_DIR=$CURRENT/crypto-config/
CRYPTO_CONFIG_FILE=$CURRENT/crypto-config.yaml

BIN_PATH="$CURRENT/../../bin"

remain_params=""
for ((i = 1; i <= $#; i++)); do
	j=${!i}
	remain_params="$remain_params $j"
done

isAPPEND=false
while getopts "i:o:a" shortname $remain_params; do
	case $shortname in
	i)
		echo "set crypto config yaml file (default: $CRYPTO_CONFIG_FILE) --config $OPTARG"
		CRYPTO_CONFIG_FILE="$OPTARG"
		;;
	o)
		echo "set crypto output directory (default: $CRYPTO_CONFIG_DIR)  --output $OPTARG"
		CRYPTO_CONFIG_DIR="$OPTARG"
		;;
	a)
		echo "append mode: not to clear CRYPTO_CONFIG_DIR"
		isAPPEND=true
		;;
	?)
		echo "unknown argument"
		exit 1
		;;
	esac
done

if [ "$isAPPEND" == "false" ]; then
	echo "clear CRYPTO_CONFIG_DIR $CRYPTO_CONFIG_DIR"
	rm -rf $CRYPTO_CONFIG_DIR
fi

# gen
cd $BIN_PATH

./cryptogen generate --config="$CRYPTO_CONFIG_FILE" --output="$CRYPTO_CONFIG_DIR"

cd -