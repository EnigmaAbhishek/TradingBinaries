#!/bin/bash

TRADE_NAME=$1
VERSION=$2

#cd /home/enigma/TradingBinaries/
cd /home/ajain/TradingBinaries/
git pull origin main
cd

declare -A BINARY_PATHS
BINARY_PATHS=(
    ["di_front"]="/teamssd/TradingBinaries/EnigmaB3Trader_$VERSION"
    ["brz_di"]="/teamssd/TradingBinaries/EnigmaB3Trader_$VERSION"
    ["brz_frt2"]="/teamssd/TradingBinaries/EnigmaB3Trader_$VERSION"
    ["brz_mid"]="/teamssd/TradingBinaries/EnigmaB3Trader_$VERSION"
    ["wdo_roll"]="/teamssd/TradingBinaries/EnigmaB3Trader_$VERSION"
    ["brz_temp"]="/teamssd/TradingBinaries/EnigmaB3Trader_$VERSION"
    ["brz_mid2"]="/teamssd/TradingBinaries/EnigmaB3Trader_$VERSION"
    ["brz_frt3"]="/teamssd/TradingBinaries/EnigmaB3Trader_$VERSION"
    ["us_frontend"]="/teamssd/TradingBinaries/EnigmaTrader_$VERSION"
    ["us_ted"]="/teamssd/TradingBinaries/EnigmaTrader_$VERSION"
    ["us_fly1"]="/teamssd/TradingBinaries/EnigmaTrader_$VERSION"
    ["us_fly3"]="/teamssd/TradingBinaries/EnigmaTrader_$VERSION"
    ["ca_us"]="/teamssd/TradingBinaries/EnigmaTMXTrader_$VERSION"
    ["ca_ted"]="/teamssd/TradingBinaries/EnigmaTMXTrader_$VERSION"
    ["eu_ted"]="/teamssd/TradingBinaries/EnigmaICEEUREXTrader_$VERSION"
    ["eu_frontend"]="/teamssd/TradingBinaries/EnigmaICEEUREXTrader_$VERSION"
    ["us_crude"]="/teamssd/TradingBinaries/EnigmaCMEICETrader_$VERSION"
    ["us_crude_front"]="teamssd/TradingBinaries/EnigmaCMEICETrader_$VERSION"
    ["au_ted"]="/teamssd/TradingBinaries/EnigmaASXTrader_$VERSION"
)

declare -A PREFIXES
PREFIXES=(
    ["di_front"]="B3_live"
    ["brz_di"]="B3_live"
    ["brz_frt2"]="B3_live"
    ["brz_mid"]="B3_live"
    ["wdo_roll"]="B3_live"
    ["brz_temp"]="B3_live"
    ["brz_mid2"]="B3_live"
    ["brz_frt3"]="B3_live"
    ["us_frontend"]="CME_live"
    ["us_ted"]="CME_live"
    ["us_fly1"]="CME_live"
    ["us_fly3"]="CME_live"
    ["ca_us"]="TMX_live"
    ["ca_ted"]="TMX_live"
    ["eu_ted"]="ICE_live"
    ["eu_frontend"]="ICE_live"
    ["us_crude"]="CME_live"
    ["us_crude_front"]="CME_live"
    ["au_ted"]="ASX_live"
)

declare -A TRADER_BINARY_NAMES
TRADER_BINARY_NAMES=(
    ["di_front"]="EnigmaB3Trader"
    ["brz_di"]="EnigmaB3Trader"
    ["brz_frt2"]="EnigmaB3Trader"
    ["brz_mid"]="EnigmaB3Trader"
    ["wdo_roll"]="EnigmaB3Trader"
    ["brz_temp"]="EnigmaB3Trader"
    ["brz_mid2"]="EnigmaB3Trader"
    ["brz_frt3"]="EnigmaB3Trader"
    ["us_frontend"]="EnigmaCMETrader"
    ["us_ted"]="EnigmaCMETrader"
    ["us_fly1"]="EnigmaCMETrader"
    ["us_fly3"]="EnigmaCMETrader"
    ["ca_us"]="EnigmaTMXTrader"
    ["ca_ted"]="EnigmaTMXTrader"
    ["eu_ted"]="EnigmaICEEUREXTrader"
    ["eu_frontend"]="EnigmaICEEUREXTrader"
    ["us_crude"]="EnigmaCMEICETrader"
    ["us_crude_front"]="EnigmaCMEICETrader"
    ["au_ted"]="EnigmaASXTrader"
)

TRADING_BINARY_PREFIX="/home/ajain/bin"
#TRADING_BINARY_PREFIX="/home/enigma/bin"

HOST_IP="mcheng@10.132.0.44"

if [[ -z "${BINARY_PATHS[$TRADE_NAME]}" ]]; then
    echo "Trade name does not exist"
    exit 1
fi

PREFIX="${PREFIXES[$TRADE_NAME]}"
DESTINATION_PATH="$TRADING_BINARY_PREFIX/${PREFIX}_${TRADE_NAME}"
TRADER_BINARY_NAME="${TRADER_BINARY_NAMES[$TRADE_NAME]}"

if [ "$TRADE_NAME" == "us_frontend" ]; then
    echo "Copying us_frontend"
    TRADING_BINARY_PREFIX="/home/infinity/bin"
    rsync -avz --info=progress2 "$HOST_IP:${BINARY_PATHS[$TRADE_NAME]}" "$TRADING_BINARY_PREFIX/CME_live_us_frontend"
    TRADING_BINARY_PATH="$TRADING_BINARY_PREFIX/CME_live_us_frontend"
else
    echo "Copying $TRADE_NAME"
    rsync -avz --info=progress2 "$HOST_IP:${BINARY_PATHS[$TRADE_NAME]}" "$DESTINATION_PATH"
    TRADING_BINARY_PATH="$DESTINATION_PATH"
fi

# Calculate the checksum of the copied binary
checksum=$(md5sum "$TRADING_BINARY_PATH" | cut -d " " -f 1)

# Read the binary_checksums.csv file
CHECKSUM_FILE="/home/ajain/TradingBinaries/binary_checksums.csv"
#CHECKSUM_FILE="/home/enigma/TradingBinaries/binary_checksums.csv"

# Check if the checksum file exists and is readable
if [ ! -f "$CHECKSUM_FILE" ] || [ ! -r "$CHECKSUM_FILE" ]; then
    echo "Checksum file not found or not readable: $CHECKSUM_FILE"
fi

match_found=false

while IFS=, read -r TRADER_NAME VERSION_BIN CHECKSUM; do
    if [ "$TRADER_NAME" == "$TRADER_BINARY_NAME" ] && [ "v$VERSION_BIN" == "$VERSION" ]; then
        if [ "$CHECKSUM" == "$checksum" ]; then
            echo "Checksums Verification passed"
            echo "Copied Binary Checksum is: $checksum"
            echo "Checksum in the binary_checksums.csv file is: $CHECKSUM"
        else
            echo "Checksums Verification failed"
            echo "Please update the checksum in the binary_checksums.csv file"
        fi
        match_found=true
        break
    fi
done < "$CHECKSUM_FILE"

if [ "$match_found" == false ]; then
    echo "No matching trader name and version found in binary_checksums.csv"
fi








