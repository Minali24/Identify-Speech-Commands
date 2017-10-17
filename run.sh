#!/bin/bash

train_cmd="utils/run.pl"
decode_cmd="utils/run.pl"


train_yesno=train_yesno
test_base_name=test_yesno

cp -r audio temp_audio


rm -rf data exp mfcc

# Data preparation


./prepare_train_test_in_data_local.sh

local/prepare_data.sh temp_audio/audio
local/prepare_dict.sh	
utils/prepare_lang.sh --position-dependent-phones false data/local/dict "<sil>" data/local/lang data/lang
local/prepare_lm.sh

# Feature extraction
for x in train_yesno test_yesno; do 
 utils/fix_data_dir.sh data/$x
 steps/make_mfcc.sh --nj 1 data/$x exp/make_mfcc/$x mfcc
 steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x mfcc
 
done


# Mono training for monophone-triphone lexicon
steps/train_mono.sh --nj 1 --cmd "$train_cmd" \
  --totgauss 1500 \
  data/train_yesno data/lang exp/mono0a 

# Triphone training
### Triphone
#  echo "Triphone training"
#  steps/align_si.sh --nj 1 --cmd "$train_cmd" \
#      data/train_yesno data/lang exp/mono0b exp/mono_ali
#  steps/train_deltas.sh  --cmd "$train_cmd"  \
 #     1000 10000 data/train_yesno data/lang exp/mono_ali exp/tri1
 # echo "Triphone training complete"
  


# Decoding for monophone based model
utils/mkgraph.sh data/lang_test_tg exp/mono0a exp/mono0a/graph_tgpr
steps/decode.sh --nj 1 --cmd "$decode_cmd" \
    exp/mono0a/graph_tgpr data/test_yesno exp/mono0a/decode_test_yesno

# Decoding using triphones
#utils/mkgraph.sh data/lang_test_tg exp/tri1 exp/tri1/graph
#steps/decode.sh --config conf/decode.config --nj 1 --cmd "$decode_cmd" exp/tri1/graph data/test_yesno exp/tri1/decode_test_yesno
#echo "Triphone decoding done."







mv input input_word
mv input_mt input












rm -rf data mfcc

# Data preparation

local/prepare_data.sh temp_audio/audio
local/prepare_dict.sh	
utils/prepare_lang.sh --position-dependent-phones false data/local/dict "<sil>" data/local/lang data/lang
local/prepare_lm.sh

# Feature extraction
for x in train_yesno test_yesno; do 
 utils/fix_data_dir.sh data/$x
 steps/make_mfcc.sh --nj 1 data/$x exp/make_mfcc/$x mfcc
 steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x mfcc
 
done


# Mono training for monophone-triphone lexicon
steps/train_mono.sh --nj 1 --cmd "$train_cmd" \
  --totgauss 1500 \
  data/train_yesno data/lang exp/mono0b 

# Triphone training
### Triphone
  echo "Triphone training"
  steps/align_si.sh --nj 1 --cmd "$train_cmd" \
      data/train_yesno data/lang exp/mono0b exp/mono_ali
  steps/train_deltas.sh  --cmd "$train_cmd"  \
      1000 10000 data/train_yesno data/lang exp/mono_ali exp/tri1
  echo "Triphone training complete"
  


# Decoding for monophone based model
utils/mkgraph.sh data/lang_test_tg exp/mono0b exp/mono0b/graph_tgpr
steps/decode.sh --nj 1 --cmd "$decode_cmd" \
    exp/mono0b/graph_tgpr data/test_yesno exp/mono0b/decode_test_yesno

# Decoding using triphones
utils/mkgraph.sh data/lang_test_tg exp/tri1 exp/tri1/graph
steps/decode.sh --config conf/decode.config --nj 1 --cmd "$decode_cmd" exp/tri1/graph data/test_yesno exp/tri1/decode_test_yesno
echo "Triphone decoding done."

for x in exp/*/decode*; do [ -d $x ] && grep WER $x/wer_* | utils/best_wer.sh; done





mv input input_mt
mv input_word input
rm -r temp_audio
