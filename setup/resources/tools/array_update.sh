
function read_yaml_array_value(){
    local -n VARIABLE="$1"
    KEY=$2
    echo $KEY
    FILE=$3
    echo $FILE
    mapfile -t array_list < <(yq e '.'"$KEY[]" $FILE)
    echo "Array elements:"
    for item in "${array_list[@]}"; do
        echo "- $item"

    done
    local declare -a ${VARIABLE}=()
    for item in "$VARIABLE"; do
        echo "- $item"
    done
    export $VARIABLE=$(yq e '.'"$KEY[]" $FILE)
    echo $VARIABLE
}
export -f read_yaml_array_value
