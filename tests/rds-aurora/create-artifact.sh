###############
## FUNCTIONS ##
###############
logKeyValuePair()
{
    echo "    $1: $2"
}
logWarning()
{
    echo "    WARNING -> $1"
}
logAction()
{
    echo ""
    echo "$1 ..."
}

############
## SCRIPT ##
############

WKDIR=$PWD
logAction "CREATING ARTIFACT"
SERVICE_NAME="standard"
logKeyValuePair "service-name" $SERVICE_NAME
cd "$WKDIR/tests/$SERVICE_NAME"
npm install
npm run pack
cd "$WKDIR"