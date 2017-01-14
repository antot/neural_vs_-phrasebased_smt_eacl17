import numpy as np
import sys

def bootstrap_resample(X, n=None):
    """ Bootstrap resample an array_like
    Parameters
    ----------
    X : array_like
      data to resample
    n : int, optional
      length of resampled array, equal to len(X) if n==None
    Results
    -------
    returns X_resamples
    """
    if n == None:
        n = len(X)

    resample_i = np.floor(np.random.rand(n)*len(X)).astype(int)
    X_resample = X[resample_i]
    return X_resample

NUMITERS=1000

scores1_f=open(sys.argv[1])
scores2_f=open(sys.argv[2])

scores_1=[]
for line in scores1_f:
    line=line.rstrip("\n")
    score=float(line)
    scores_1.append(score)

scores_2=[]
for line in scores2_f:
    line=line.rstrip("\n")
    score=float(line)
    scores_2.append(score)

if len(scores_1) != len(scores_2):
    print >> sys.stderr, "number of scores is different"
    exit(1)

times1win=0
times2win=0

for iter in xrange(NUMITERS):
    X = np.arange(len(scores_1))
    X_resample=bootstrap_resample(X)
    sum1=0.0
    sum2=0.0
    for idx in X_resample:
        sum1+=scores_1[idx]
        sum2+=scores_2[idx]
    avg1=sum1/len(X_resample)
    avg2=sum2/len(X_resample)
    if avg1 > avg2:
        times1win+=1
    elif avg2 > avg1:
        times2win+=1

print "Score 1 is higher than score 2 "+str(times1win*1.0/NUMITERS)+" times"
print "Score 2 is higher than score 1 "+str(times2win*1.0/NUMITERS)+" times"
