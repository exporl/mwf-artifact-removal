% subject name can be specified by either the string (e.g. 'alex') or by a
% number from 1 to 10.
name = 1; % retrieves data from 'alex'

% artifact name is specified by a string indicating artifact type (e.g.
% 'eyeblink', 'muscle')
artifact = 'eyeblink';

% retrieve EEG data with 'eyeblink' artifacts from subject 1 ('alex')
% EEG data y is in channels x samples format
[y, Fs, duration] = get_data(name, artifact);

% retrieve EEG artifact mask for subject 1 ('alex')
redo = 0; % put to 1 if you want to use the eyeballgui to make the mask
mask = get_artifact_mask(name, artifact, redo);

% set some processing parameters in struct p
p = filter_params('delay', 3, 'rank', 'poseig');

y_orig = y;

% SNS
y = nt_sns(y',63)';

X = y';
C0 = X'*X;
[P,D] = eig(C0);
N = mpower(D,-0.5);
Z = X*P*N;

L = eye(size(Z,1));
L(mask==0,:) = [];
Zbar = L*Z;

C1 = Zbar'*Zbar;
[Q,Dz] = eig(C1);

Ybar = Zbar*Q;

W = P*N*Q;
Y = X*W;

E = eye(size(W,1));
comp_rem = [63,64];
E(comp_rem,comp_rem) = 0;

X_rec = Y*E/W;

v_JD = X_rec';
d_JD = (X-X_rec)';

[SER_JD, ARR_JD]  = filter_performance(y_orig, d_JD, mask);


% compute GEVD-MWF for data y
[w]         = filter_compute(y, mask, p);

% apply the computed filter w to data y
% v and d are resp. clean data and artifact estimate
[v, d]      = filter_apply(y, w);

% compute performance parameters for the artifact removal
[SER, ARR]  = filter_performance(y_orig, d, mask);

% plot result of artifact removal
chan = 1;  % Fp1
figure
plot(y(chan,:)); hold on; plot(d(chan,:),'red');
legend('raw data', 'artifact estimate')

figure
plot(y(chan,:)); hold on; plot(v(chan,:),'green');
legend('raw data', 'clean data')

