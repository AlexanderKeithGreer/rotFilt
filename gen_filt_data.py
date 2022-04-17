import numpy as np
import numpy.random as ra
import scipy.signal as sig
import matplotlib.pyplot as plt

#This is intended to lowpass filter noise and feed that into a

def genDataLP(l_data,f_s):
    """
    Generates data. Assumes that fs=12MHz, and that the LPF
      will run at 0.5MHz
    """
    data = np.zeros(l_data, dtype=np.complex128)
    data += ra.randn(l_data)
    data += 1j*ra.randn(l_data)
    filt = sig.firwin(20, 0.2e6,fs=f_s)
    data = np.convolve(data, filt, mode="same")
    return data

def writeToCSV(bits, ratio, mixed, interf, file=""):
    """
    Uses bits to compute the dynamic range, then scales
        the I and Q components of mixed and interf such that
        the maximum of the four is at ratio to the dynamic range
    This is then written to a csv, with format:
        int.i,int.q,mix.i,mix.q
    """
    l_data = len(interf)
    int_i = np.real(interf)
    int_q = np.imag(interf)
    mix_i = np.real(mixed)
    mix_q = np.imag(mixed)

    if (type(ratio) != np.int64):
        print("WARN: ratio type wrong?")

    dyn_range = 2**(bits-2) #Signed integer
    dyn_max = np.max(np.abs(np.concatenate((int_i, int_q, mix_i, mix_q))))
    if (file==""):
        print("dyn_max = ", dyn_max)
        print("dyn_range = ", dyn_range)
        print("(dyn_range/(dyn_max*ratio) = ", (dyn_range/(dyn_max*ratio)))
    int_i = int_i*(dyn_range/dyn_max)/ratio
    int_q = int_q*(dyn_range/dyn_max)/ratio
    mix_i = mix_i*(dyn_range/dyn_max)/ratio
    mix_q = mix_q*(dyn_range/dyn_max)/ratio

    output = np.zeros([l_data, 4], dtype=np.int64)
    output[:,0] = np.int64(np.round(int_i[:]))
    output[:,1] = np.int64(np.round(int_q[:]))
    output[:,2] = np.int64(np.round(mix_i[:]))
    output[:,3] = np.int64(np.round(mix_q[:]))
    if (file==""):
        print("WARN: No file specified")
        print("output = \n", output)
    else:
        np.savetxt(file, output, fmt='%.5d', delimiter=",")

def writeToCSV_test():
    """
    Only testing via visual inspection
    """
    dataInt = np.array([1,2,1+4j])
    dataMix = np.array([-1,2+2j,-2j])
    writeToCSV(8,2,dataInt,dataMix)

def main():
    "Generates data via the "
    n_samp = 1000
    f_interf = 0.7e6
    f_s = 12e6
    bits = 16
    ratio = 8

    time = np.arange(0, n_samp/f_s, 1/f_s, dtype=np.complex128);
    desired = genDataLP(n_samp, f_s)
    interf = np.exp(2j*np.pi*f_interf*time)
    mixed = desired + interf

    writeToCSV(bits, ratio, mixed, interf, file="input_rotFilt.csv")

    plt.plot(np.abs(desired), label="Abs")
    plt.plot(np.angle(desired), label="Angle")
    plt.plot(np.real(interf), label="R(interf)")
    plt.legend()
    plt.show()

main()
