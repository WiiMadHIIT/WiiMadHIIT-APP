import 'dart:math';

/// Fast Fourier Transform (FFT) Utility
/// Apple-level optimized FFT implementation for real-time spectral analysis
/// Provides efficient frequency domain analysis for strike sound detection
class FFT {
  static const double _twoPi = 2.0 * pi;
  
  /// Apple optimization: Pre-computed twiddle factors for efficiency
  static final Map<int, List<Complex>> _twiddleFactors = {};
  
  /// Apple optimization: Pre-computed bit-reversal tables
  static final Map<int, List<int>> _bitReversalTables = {};
  
  /// Apple optimization: Hanning window coefficients
  static List<double>? _hanningWindow;
  
  /// Apple optimization: Hamming window coefficients
  static List<double>? _hammingWindow;
  
  /// Apple optimization: Blackman window coefficients
  static List<double>? _blackmanWindow;
  
  /// Apple optimization: Initialize FFT with pre-computed data
  static void initialize(int maxSize) {
    _precomputeTwiddleFactors(maxSize);
    _precomputeBitReversalTables(maxSize);
    _precomputeWindows(maxSize);
  }
  
  /// Apple optimization: Pre-compute twiddle factors for efficiency
  static void _precomputeTwiddleFactors(int maxSize) {
    for (int size = 2; size <= maxSize; size *= 2) {
      if (!_twiddleFactors.containsKey(size)) {
        final factors = <Complex>[];
        for (int k = 0; k < size / 2; k++) {
          final angle = -_twoPi * k / size;
          factors.add(Complex(cos(angle), sin(angle)));
        }
        _twiddleFactors[size] = factors;
      }
    }
  }
  
  /// Apple optimization: Pre-compute bit-reversal tables
  static void _precomputeBitReversalTables(int maxSize) {
    for (int size = 2; size <= maxSize; size *= 2) {
      if (!_bitReversalTables.containsKey(size)) {
        final table = <int>[];
        final log2Size = (log(size) / log(2)).round();
        
        for (int i = 0; i < size; i++) {
          int reversed = 0;
          for (int j = 0; j < log2Size; j++) {
            reversed = (reversed << 1) | ((i >> j) & 1);
          }
          table.add(reversed);
        }
        _bitReversalTables[size] = table;
      }
    }
  }
  
  /// Apple optimization: Pre-compute window functions
  static void _precomputeWindows(int maxSize) {
    if (_hanningWindow == null || _hanningWindow!.length < maxSize) {
      _hanningWindow = List.generate(maxSize, (i) {
        return 0.5 - 0.5 * cos(_twoPi * i / (maxSize - 1));
      });
    }
    
    if (_hammingWindow == null || _hammingWindow!.length < maxSize) {
      _hammingWindow = List.generate(maxSize, (i) {
        return 0.54 - 0.46 * cos(_twoPi * i / (maxSize - 1));
      });
    }
    
    if (_blackmanWindow == null || _blackmanWindow!.length < maxSize) {
      _blackmanWindow = List.generate(maxSize, (i) {
        return 0.42 - 0.5 * cos(_twoPi * i / (maxSize - 1)) + 0.08 * cos(2 * _twoPi * i / (maxSize - 1));
      });
    }
  }
  
  /// Apple optimization: Perform FFT on real input data
  static List<Complex> fft(List<double> input, {WindowType windowType = WindowType.hanning}) {
    final size = input.length;
    
    // Ensure size is power of 2
    if (!_isPowerOfTwo(size)) {
      throw ArgumentError('FFT size must be a power of 2, got: $size');
    }
    
    // Apply window function
    final windowedInput = _applyWindow(input, windowType);
    
    // Convert to complex numbers
    final complexInput = windowedInput.map((x) => Complex(x, 0.0)).toList();
    
    // Perform FFT
    return _fftRadix2(complexInput);
  }
  
  /// Apple optimization: Perform inverse FFT
  static List<double> ifft(List<Complex> input) {
    final size = input.length;
    
    if (!_isPowerOfTwo(size)) {
      throw ArgumentError('IFFT size must be a power of 2, got: $size');
    }
    
    // Conjugate input
    final conjugated = input.map((c) => c.conjugate).toList();
    
    // Perform FFT on conjugated input
    final fftResult = _fftRadix2(conjugated);
    
    // Conjugate and scale result
    return fftResult.map((c) => c.conjugate.real / size).toList();
  }
  
  /// Apple optimization: Radix-2 FFT implementation
  static List<Complex> _fftRadix2(List<Complex> input) {
    final size = input.length;
    
    // Bit-reversal permutation
    final bitReversed = _bitReversePermutation(input, size);
    
    // FFT computation
    final result = List<Complex>.from(bitReversed);
    
    for (int stage = 1; stage <= (log(size) / log(2)).round(); stage++) {
      final stageSize = 1 << stage;
      final halfStageSize = stageSize >> 1;
      
      for (int group = 0; group < size; group += stageSize) {
        for (int k = 0; k < halfStageSize; k++) {
          final twiddleFactor = _getTwiddleFactor(size, (k * (size / stageSize)).round());
          final evenIndex = group + k;
          final oddIndex = group + k + halfStageSize;
          
          final even = result[evenIndex];
          final odd = result[oddIndex];
          
          result[evenIndex] = even + twiddleFactor * odd;
          result[oddIndex] = even - twiddleFactor * odd;
        }
      }
    }
    
    return result;
  }
  
  /// Apple optimization: Bit-reversal permutation using pre-computed table
  static List<Complex> _bitReversePermutation(List<Complex> input, int size) {
    final table = _bitReversalTables[size];
    if (table == null) {
      throw StateError('Bit reversal table not pre-computed for size: $size');
    }
    
    final result = List<Complex>.filled(size, Complex.zero);
    for (int i = 0; i < size; i++) {
      result[table[i]] = input[i];
    }
    return result;
  }
  
  /// Apple optimization: Get twiddle factor from pre-computed table
  static Complex _getTwiddleFactor(int size, int k) {
    final factors = _twiddleFactors[size];
    if (factors == null) {
      throw StateError('Twiddle factors not pre-computed for size: $size');
    }
    
    return factors[k % ((size / 2).round())];
  }
  
  /// Apple optimization: Apply window function to input
  static List<double> _applyWindow(List<double> input, WindowType windowType) {
    final size = input.length;
    List<double> window;
    
    switch (windowType) {
      case WindowType.hanning:
        window = _hanningWindow ?? [];
        break;
      case WindowType.hamming:
        window = _hammingWindow ?? [];
        break;
      case WindowType.blackman:
        window = _blackmanWindow ?? [];
        break;
      case WindowType.none:
        return input;
    }
    
    if (window.length < size) {
      throw StateError('Window not pre-computed for size: $size');
    }
    
    return List.generate(size, (i) => input[i] * window[i]);
  }
  
  /// Apple optimization: Check if number is power of 2
  static bool _isPowerOfTwo(int n) {
    return n > 0 && (n & (n - 1)) == 0;
  }
  
  /// Apple optimization: Get power spectrum from FFT result
  static List<double> getPowerSpectrum(List<Complex> fftResult) {
    return fftResult.map((c) => c.magnitudeSquared).toList();
  }
  
  /// Apple optimization: Get magnitude spectrum from FFT result
  static List<double> getMagnitudeSpectrum(List<Complex> fftResult) {
    return fftResult.map((c) => c.magnitude).toList();
  }
  
  /// Apple optimization: Get phase spectrum from FFT result
  static List<double> getPhaseSpectrum(List<Complex> fftResult) {
    return fftResult.map((c) => c.phase).toList();
  }
  
  /// Apple optimization: Get frequency bins for given sample rate
  static List<double> getFrequencyBins(int fftSize, double sampleRate) {
    return List.generate(fftSize, (i) => i * sampleRate / fftSize);
  }
  
  /// Apple optimization: Get dominant frequency from FFT result
  static double getDominantFrequency(List<Complex> fftResult, double sampleRate) {
    final powerSpectrum = getPowerSpectrum(fftResult);
    final frequencyBins = getFrequencyBins(fftResult.length, sampleRate);
    
    int maxIndex = 0;
    double maxPower = powerSpectrum[0];
    
    for (int i = 1; i < powerSpectrum.length; i++) {
      if (powerSpectrum[i] > maxPower) {
        maxPower = powerSpectrum[i];
        maxIndex = i;
      }
    }
    
    return frequencyBins[maxIndex];
  }
  
  /// Apple optimization: Get spectral centroid
  static double getSpectralCentroid(List<Complex> fftResult, double sampleRate) {
    final powerSpectrum = getPowerSpectrum(fftResult);
    final frequencyBins = getFrequencyBins(fftResult.length, sampleRate);
    
    double weightedSum = 0.0;
    double totalPower = 0.0;
    
    for (int i = 0; i < powerSpectrum.length; i++) {
      weightedSum += frequencyBins[i] * powerSpectrum[i];
      totalPower += powerSpectrum[i];
    }
    
    return totalPower > 0 ? weightedSum / totalPower : 0.0;
  }
  
  /// Apple optimization: Get spectral rolloff
  static double getSpectralRolloff(List<Complex> fftResult, double sampleRate, {double percentile = 0.85}) {
    final powerSpectrum = getPowerSpectrum(fftResult);
    final frequencyBins = getFrequencyBins(fftResult.length, sampleRate);
    
    final totalPower = powerSpectrum.reduce((a, b) => a + b);
    final threshold = totalPower * percentile;
    
    double cumulativePower = 0.0;
    for (int i = 0; i < powerSpectrum.length; i++) {
      cumulativePower += powerSpectrum[i];
      if (cumulativePower >= threshold) {
        return frequencyBins[i];
      }
    }
    
    return frequencyBins.last;
  }
  
  /// Apple optimization: Get spectral bandwidth
  static double getSpectralBandwidth(List<Complex> fftResult, double sampleRate) {
    final centroid = getSpectralCentroid(fftResult, sampleRate);
    final powerSpectrum = getPowerSpectrum(fftResult);
    final frequencyBins = getFrequencyBins(fftResult.length, sampleRate);
    
    double weightedSum = 0.0;
    double totalPower = 0.0;
    
    for (int i = 0; i < powerSpectrum.length; i++) {
      final diff = frequencyBins[i] - centroid;
      weightedSum += (diff * diff) * powerSpectrum[i];
      totalPower += powerSpectrum[i];
    }
    
    return totalPower > 0 ? sqrt(weightedSum / totalPower) : 0.0;
  }
  
  /// Apple optimization: Get zero-crossing rate from time domain signal
  static double getZeroCrossingRate(List<double> signal) {
    int crossings = 0;
    for (int i = 1; i < signal.length; i++) {
      if ((signal[i] >= 0) != (signal[i - 1] >= 0)) {
        crossings++;
      }
    }
    return crossings / (signal.length - 1);
  }
  
  /// Apple optimization: Get RMS energy
  static double getRMSEnergy(List<double> signal) {
    final sum = signal.map((x) => x * x).reduce((a, b) => a + b);
    return sqrt(sum / signal.length);
  }
  
  /// Apple optimization: Get weighted RMS energy with frequency weighting
  static double getWeightedRMSEnergy(List<double> signal, List<double> weights) {
    if (signal.length != weights.length) {
      throw ArgumentError('Signal and weights must have same length');
    }
    
    double weightedSum = 0.0;
    double weightSum = 0.0;
    
    for (int i = 0; i < signal.length; i++) {
      weightedSum += (signal[i] * signal[i]) * weights[i];
      weightSum += weights[i];
    }
    
    return weightSum > 0 ? sqrt(weightedSum / weightSum) : 0.0;
  }
}

/// Complex number class for FFT calculations
class Complex {
  final double real;
  final double imaginary;
  
  const Complex(this.real, this.imaginary);
  
  static const Complex zero = Complex(0.0, 0.0);
  static const Complex one = Complex(1.0, 0.0);
  static const Complex i = Complex(0.0, 1.0);
  
  Complex operator +(Complex other) {
    return Complex(real + other.real, imaginary + other.imaginary);
  }
  
  Complex operator -(Complex other) {
    return Complex(real - other.real, imaginary - other.imaginary);
  }
  
  Complex operator *(Complex other) {
    return Complex(
      real * other.real - imaginary * other.imaginary,
      real * other.imaginary + imaginary * other.real,
    );
  }
  
  Complex operator /(Complex other) {
    final denominator = other.real * other.real + other.imaginary * other.imaginary;
    return Complex(
      (real * other.real + imaginary * other.imaginary) / denominator,
      (imaginary * other.real - real * other.imaginary) / denominator,
    );
  }
  
  Complex get conjugate => Complex(real, -imaginary);
  
  double get magnitude => sqrt(real * real + imaginary * imaginary);
  
  double get magnitudeSquared => real * real + imaginary * imaginary;
  
  double get phase => atan2(imaginary, real);
  
  @override
  String toString() {
    if (imaginary >= 0) {
      return '$real + ${imaginary}i';
    } else {
      return '$real - ${-imaginary}i';
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Complex &&
           real == other.real &&
           imaginary == other.imaginary;
  }
  
  @override
  int get hashCode => real.hashCode ^ imaginary.hashCode;
}

/// Window function types for FFT
enum WindowType {
  none,
  hanning,
  hamming,
  blackman,
} 