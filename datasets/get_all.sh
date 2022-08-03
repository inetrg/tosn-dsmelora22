to_list () {
    while read -r data; do
        echo $data
    done | cut -d"," -f$1 | tail -n+2 | paste -sd, - | sed 's/\(.*\)/"\[\1\]"/'
}

get_stats () {
    TOA_FILE=$(mktemp)
    ./duty_cycle.sh $1 > $TOA_FILE

    paste -d"," <(./print_conf.awk $1) <(./gen_stats.awk $1) <(./tx_stats.awk $1) <(./cca_stats.awk $1) <(echo "toa_node_agg";cat $TOA_FILE | to_list 2) <(echo "toa_node_roles";cat $TOA_FILE | to_list 7) <(echo "toa_node_dt";cat $TOA_FILE | to_list 8) | ( [[ "$2" -eq 0 ]] && cat || tail -n+2)

    rm $TOA_FILE
}

calc_prr () {
    while read -r data; do
        echo $data
    done | awk '$2 {c++} {n++} END{print c/n*100}'
}

get_moving_avg () {
    ./get_dsme_times.awk $1 | sort -k1 | ./moving_average.awk | tail -n+2
}

CWD=$(pwd)

# Change current working directory
cd parsers

echo "Generate data for Coexistence with LoRaWAN"
(echo "prr_baseline,prr_cross";paste -d"," <(./get_dsme_times.awk ../coexistence/raw_baseline.dat | calc_prr) \
    <(./get_dsme_times.awk ../coexistence/raw_cross.dat | calc_prr)) > $CWD/prr_coexistence.csv

echo "Generate moving average PRR for experiments with jamming signal"
(echo "t_r1,prr_r1,t_r2,prr_r2,t_r3,prr_r3";
paste -d"," <(get_moving_avg ../coexistence/interference_r1.dat) \
            <(get_moving_avg ../coexistence/interference_r2.dat) \
            <(get_moving_avg ../coexistence/interference_r3.dat)
) > $CWD/interference_prr_moving_avg.csv

echo "Generate Data Transmission data"
SKIP_HEADER=0
find $CWD/data_transmission -name "*.log" | while read -r data; do
    get_stats $data $SKIP_HEADER
    SKIP_HEADER=1
done > $CWD/data_transmission.csv
