data {
    int<lower = 0> n;           // number of lakes
    int<lower = 0> ne;          // number of eco-regions
    real TN_logobs[n];          // observations of ln(TN)
    real TP_logobs[n];          // observations of ln(TP)
    real NAPI[n];               // Net Anthropogenic Phosphorus Inputs
    real NANI[n];               // Net Anthropogenic Nitrogen Inputs
    real<lower = 0> WSArea[n];  // watershed area of each lake
    real<lower = 0> LF[n];      // pct of forest in the watershed
    real<lower = 0> LW[n];      // pct of wetland in the watershed
    real<lower = 0> Chla[n];    // Chla data
    real<lower = 0> disc[n];    // outflow discharge of lakes (m^3/day)
    real<lower = 0> Vol[n];     // lake volumes
    int<lower = 0> ecoN[n];     // eco-region of each lake
}

parameters {
    // global parameters
    real<lower = 0> aN_mu;
    real<lower = 0> aN_sigma;
    real<lower = 0> aP_mu;
    real<lower = 0> aP_sigma;
    real<lower = 0> bN_mu;
    real<lower = 0> bN_sigma;
    real<lower = 0> bP_mu;
    real<lower = 0> bP_sigma;
    real<lower = 0> mN_mu;
    real<lower = 0> mN_sigma;
    real<lower = 0> mP_mu;
    real<lower = 0> mP_sigma;
    real<lower = 0> SN_mu;
    real<lower = 0> SN_sigma;
    real<lower = 0> SP_mu;
    real<lower = 0> SP_sigma;
    real theta1_mu;
    real<lower = 0> theta1_sigma;
    real theta2_mu;
    real<lower = 0> theta2_sigma;
    real theta3_mu;
    real<lower = 0> theta3_sigma;
    real theta4_mu;
    real<lower = 0> theta4_sigma;
    real theta5_mu;
    real<lower = 0> theta5_sigma;
    real theta6_mu;
    real<lower = 0> theta6_sigma;
    real theta7_mu;
    real<lower = 0> theta7_sigma;
    real theta8_mu;
    real<lower = 0> theta8_sigma;

    // submodel parameters
    real<lower = 0> aN[ne];       // biological retention rate of N
    real<lower = 0> aP[ne];       // biological retention rate of P
    real<lower = 0> bN[ne];       // shape parameter of N retention
    real<lower = 0> bP[ne];       // shape parameter of P retention
    real<lower = 1> mN[ne];       // half saturation constant for biological retention rate of N
    real<lower = 1> mP[ne];       // half saturation constant for biological retention rate of P
    real<lower = 0> SN[ne];       // sedimentation rate of N
    real<lower = 0> SP[ne];       // sedimentation rate of P
    real<lower = 1E-15> sigma[2];  // obs error
    real theta1[ne];               // parameters for estimation of N/P loading
    real theta2[ne];               // parameters for estimation of N/P loading
    real theta3[ne];               // parameters for estimation of N/P loading
    real theta4[ne];               // parameters for estimation of N/P loading
    real theta5[ne];               // parameters for estimation of N/P loading
    real theta6[ne];               // parameters for estimation of N/P loading
    real theta7[ne];               // parameters for estimation of N/P loading
    real theta8[ne];               // parameters for estimation of N/P loading
}

transformed parameters {
    real<lower = 0> TN[n];     // estimations of TN
    real<lower = 0> TP[n];     // estimations of TP
    real<lower = 0> Nload[n];  // estimations of N loading
    real<lower = 0> Pload[n];  // estimations of P loading

    // estimations of NP loading(FIRST TRY)
    for (it in 1:n){
        Nload[it] = exp(theta1[ecoN[it]]*asinh(NANI[it]/2) + theta2[ecoN[it]]*LF[it] + theta3[ecoN[it]]*LW[it] + theta4[ecoN[it]])*1e3/365*WSArea[it]; // gN/day
        Pload[it] = exp(theta5[ecoN[it]]*asinh(NAPI[it]/2) + theta6[ecoN[it]]*LF[it] + theta7[ecoN[it]]*LW[it] + theta8[ecoN[it]])*1e3/365*WSArea[it]; // gP/day
        TN[it] = (Nload[it] + aN[ecoN[it]] * pow(Chla[it],bN[ecoN[it]]) / (pow(Chla[it],bN[ecoN[it]]) + pow(mN[ecoN[it]],bN[ecoN[it]]))) / (disc[it] + SN[ecoN[it]] * Vol[it]);
        TP[it] = (Pload[it] + aP[ecoN[it]] * pow(Chla[it],bP[ecoN[it]]) / (pow(Chla[it],bP[ecoN[it]]) + pow(mP[ecoN[it]],bP[ecoN[it]]))) / (disc[it] + SP[ecoN[it]] * Vol[it]);
    }
}

model {
    aN_mu ~ normal(30000,3000); //10000,1000
    aN_sigma ~ normal(2000,300);
    aP_mu ~ normal(5000,500);
    aP_sigma ~ normal(400,100);
    bN_mu ~ normal(1.3,0.3);
    bN_sigma ~ normal(1.0,0.1);
    bP_mu ~ normal(2.1,0.3);
    bP_sigma ~ normal(1.0,0.1);
    mN_mu ~ normal(12.0,2.0);
    mN_sigma ~ normal(2.0,1.0);
    mP_mu ~ normal(2.0,0.1);
    mP_sigma ~ normal(1.0,0.1);
    SN_mu ~ normal(0.001,0.001);
    SN_sigma ~ normal(0.001,0.01);
    SP_mu ~ normal(0.010,0.003); //0.04, 0.04
    SP_sigma ~ normal(0.01,0.003); // 0.04, 0.04
    theta1_mu ~ normal(0.50,0.05);  //0.5
    theta1_sigma ~ normal(0.05,0.01);
    theta2_mu ~ normal(-0.05,0.004);
    theta2_sigma ~ normal(0.010,0.1);
    theta3_mu ~ normal(-0.02,0.006);
    theta3_sigma ~ normal(0.010,0.006);
    theta4_mu ~ normal(3.00,0.2); //2.2
    theta4_sigma ~ normal(0.2,0.1); //0.3
    theta5_mu ~ normal(0.23,0.05);
    theta5_sigma ~ normal(0.1,0.02);
    theta6_mu ~ normal(-0.01,0.006);
    theta6_sigma ~ normal(0.011,0.006);
    theta7_mu ~ normal(-0.02,0.007);
    theta7_sigma ~ normal(0.010,0.008);
    theta8_mu ~ normal(3.6,0.5); // 3.6
    theta8_sigma ~ normal(3.28,0.13);
    aN ~ normal(aN_mu,aN_sigma);
    aP ~ normal(aP_mu,aP_sigma);
    bN ~ normal(bN_mu,bN_sigma);
    bP ~ normal(bP_mu,bP_sigma);
    mN ~ normal(mN_mu,mN_sigma);
    mP ~ normal(mP_mu,mP_sigma);
    SN ~ normal(SN_mu,SN_sigma);
    SP ~ normal(SP_mu,SP_sigma);
    theta1 ~ normal(theta1_mu, theta1_sigma);
    theta2 ~ normal(theta2_mu, theta2_sigma);
    theta3 ~ normal(theta3_mu, theta3_sigma);
    theta4 ~ normal(theta4_mu, theta4_sigma);
    theta5 ~ normal(theta5_mu, theta5_sigma);
    theta6 ~ normal(theta6_mu, theta6_sigma);
    theta7 ~ normal(theta7_mu, theta7_sigma);
    theta8 ~ normal(theta8_mu, theta8_sigma);

    TN_logobs[1:n] ~ normal(log(TN[1:n]), sigma[1]);
    TP_logobs[1:n] ~ normal(log(TP[1:n]), sigma[2]);
}