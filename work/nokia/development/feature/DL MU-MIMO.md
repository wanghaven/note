# CB008305
## MU-SINR calculation
### WB BF UEs paired with oDFT beams

$$
\begin{align*}
muSinrUeLinear_{A,i, layer} &= \frac{1}{rrmDlMuSinrFactor * \dfrac{N}{suSinrUeLinear_{i}} + rrmDlMuIntfFactor * \sum_{j\in A \& \& i \neq j}(\dfrac{\sum_{k\in [0\dots rankMuUe(j)]}\tilde{G}_{i,w(j,k)}}{\tilde{G}_{i,w(i,layer)}})} \\
musinrUeDb_{A,i} &=
\begin{cases}
\dfrac{10}{rankMuUe_{i}}\sum\limits_{layer\in[0\dots rankMuUe(j)]}\log_{10}(muSinrUeLinear_{A,i,layer}), & \text{if } rrmDlMuSinrMethod = 0 \\[10pt]
\min\limits_{layer\in[0\dots rankMuUe(j)]} 10\cdot\log_{10}(muSinrUeLinear_{A,i,layer}), & \text{if } rrmDlMuSinrMethod = 1
\end{cases}
\end{align*}
$$

Where: 
$$
\begin{align*}
& suSinrUeLinear_{i}: \text{the linear value of SU-SINR which is calculated from rrmCorrAvgCqi without OLLA correction (rrmDeltaCqi = 0).} \\
& \tilde{G}: \text{it represents DL BF gain, see definition in 5G\_UP\_ALG\_7442\_replaced(11143159)}, \tilde{G}_{i,w} = \delta * \tilde{G}^{'}_{i,w} = \delta * \tilde{G}^{'}_{i,w_{v}} * \tilde{G}^{'}_{i,w_{h}} = \delta * {(W^{H}_{v} \tilde{R}_{i,v}W_{v})} * {(W^{H}_{h} \tilde{R}_{i,h}W_{h})} \\
& N: the "equivalent" number of paired UEs in current virtual UE after applying power scaling \\
& txPowerFactor = min(1.0, \frac{freePrb+\sum_{A\in(all Viturl UE)}{allocatedPrbVirtualUe_{A}}}{Sum_{A\in(all Virtual UE)}{virtualUeSize_{A}* allocatedPrbVirtualUe_{A}}}) \\
& N = \frac{1}{txPowerFactor}
\end{align*}
$$


### WB BF UEs paired with EBB beams
$$
musinrUeDb_{A,i} = susinrUeDb_{A,i} + pairing_power_loss_{A,i} + zf_power_loss_{A,i} \\
$$

Where:
$$
\begin{align*}
pairing_power_loss_{A,i} &= 10*log10(numSuLayers/numMuLayers) \\
zf_power_loss_{A,i} &= 10*log10(1-\sum_{j}{corr(i,j)^{2}})
\end{align*}
$$