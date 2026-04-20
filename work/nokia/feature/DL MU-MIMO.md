# CB008305
## MU-SINR calculation
### WB BF UEs paired with oDFT beams

$$
muSinrUeLinear_{A,i, layer} = \frac{1}{rrmDlMuSinrFactor \cdot \dfrac{N}{suSinrUeLinear_{i}} + rrmDlMuIntfFactor \cdot \sum_{j\in A \& \& i \neq j}(\dfrac{\sum_{k\in [0\dots rankMuUe(j)]}\tilde{G}_{i,v(j,k)}}{\tilde{G}_{i,v(i,layer)}})}$$


$$
suSinrUeLinear_{i}: \text{the linear value of SU-SINR which is calculated from rrmCorrAvgCqi without OLLA correction (rrmDeltaCqi = 0).}
$$
$$
\tilde{G}: \text{it represents DL BF gain, see definition in 5G\_UP\_ALG\_7442\_replaced(11143159)}
$$
$$
\tilde{G}_{i,w} = \delta \cdot \tilde{G}^{'}_{i,w} 
= \delta \cdot \tilde{G}^{'}_{i,w_{v}} \cdot \tilde{G}^{'}_{i,w_{h}} 
= \delta \cdot {(W^{H}_{v} \tilde{R}_{i,v}W_{v})} \cdot {(W^{H}_{h} \tilde{R}_{i,h}W_{h})}
$$
