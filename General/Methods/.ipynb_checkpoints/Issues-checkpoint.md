Email contact with Harald & Muresan
> Dear Daniel,
>
> Thanks a lot for taking the time to implement the method in Fieldtrip! This will strongly boost its visibility.
>
> Regarding code, sure, you are more than welcome to use the example from the paper and the toy data from the code we provided!
>
> Harald (in CC) has tested your implementation against ours and the only difference seems to be in scaling. Perhaps you two can discuss more about this.
>
> The paper is now at PNAS - still waiting to see if they want to review it or not. In the meantime, we want to develop connectivity methods based on Superlets, i.e. coherence and phase-locking. Once we have those, it would be great to implement them in Matlab as well. Let's keep in touch!
>
> Thanks again for all your help!
>
> Warm regards,
> Raul
>

Update email:

> Dear Daniel,
>
> I'm attaching the code that I used to test your implementation (test.m), together with the code which generates the surrogate data (toydata.m). It's the same surrogate data as in our paper, figure 3. I tested it using your most recent commit for the ft_freqanalysis file on GitHub (uploaded 2 days ago).
>
> The only striking difference I see lies in the values themselves, as the values produced by our implementation matches the amplitudes of the sine waves. This is most likely a normalization issue and should go away if you're z-scoring.
> I must admit I've never used FieldTrip before, so I'm not sure how it works under the hood and even if I wrote the analysis code correctly. That being said, in our implementation we use 2.5 as the SD for the Gaussian (FieldTrip uses 3 as default), but even if I set cfg.superlets.gwidth to 2.5 the scaling issue is not resolved.
>
> If you wish to have the right values, my opinion is that you should drop ft_specest_wavelet. Do the necessary marshalling, create the Morlet wavelets yourself and do the convolution (using conv, for example). Our function (asrwt.m) should point you in the right direction.
>
> Let me know if I missed anything in the analysis file.
>
> Cheers,
> Harald

![comparison](./Tests/ft_vs_own.png)

