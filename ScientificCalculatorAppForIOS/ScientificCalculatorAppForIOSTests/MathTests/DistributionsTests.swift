import XCTest
@testable import ScientificCalculatorAppForIOS

final class DistributionsTests: XCTestCase {
    
    // MARK: - Normal Distribution PDF Tests
    
    func test_Normal_PDF_StandardNormal_AtZero() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.pdf(0), 0.3989, accuracy: 0.001)
    }
    
    func test_Normal_PDF_StandardNormal_AtOne() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.pdf(1), 0.2420, accuracy: 0.001)
    }
    
    func test_Normal_PDF_StandardNormal_AtNegativeOne() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.pdf(-1), dist.pdf(1), accuracy: 1e-15)
    }
    
    func test_Normal_PDF_NonStandard_AtMean() throws {
        let dist = try NormalDistribution(mean: 100, stdDev: 15)
        XCTAssertEqual(dist.pdf(100), 1.0 / (15 * sqrt(2 * Double.pi)), accuracy: 0.0001)
    }
    
    // MARK: - Normal Distribution CDF Tests
    
    func test_Normal_CDF_StandardNormal_AtZero() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.cdf(0), 0.5, accuracy: 0.001)
    }
    
    func test_Normal_CDF_StandardNormal_At196() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.cdf(1.96), 0.975, accuracy: 0.001)
    }
    
    func test_Normal_CDF_StandardNormal_AtNegative196() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.cdf(-1.96), 0.025, accuracy: 0.001)
    }
    
    func test_Normal_CDF_StandardNormal_AtOne() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.cdf(1.0), 0.8413, accuracy: 0.001)
    }
    
    func test_Normal_CDF_StandardNormal_AtNegativeOne() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.cdf(-1.0), 0.1587, accuracy: 0.001)
    }
    
    func test_Normal_CDF_NonStandard_AtMean() throws {
        let dist = try NormalDistribution(mean: 100, stdDev: 15)
        XCTAssertEqual(dist.cdf(100), 0.5, accuracy: 0.001)
    }
    
    func test_Normal_CDF_NonStandard_AtOneSigma() throws {
        let dist = try NormalDistribution(mean: 100, stdDev: 15)
        XCTAssertEqual(dist.cdf(115), 0.8413, accuracy: 0.001)
    }
    
    // MARK: - Normal Distribution Upper CDF Tests
    
    func test_Normal_UpperCDF_AtZero() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.upperCdf(0), 0.5, accuracy: 0.001)
    }
    
    func test_Normal_UpperCDF_At196() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.upperCdf(1.96), 0.025, accuracy: 0.001)
    }
    
    // MARK: - Normal Distribution Between Tests
    
    func test_Normal_Between_ReturnsCorrect() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.between(-1.96, 1.96), 0.95, accuracy: 0.01)
    }
    
    func test_Normal_Between_OneSigma() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.between(-1.0, 1.0), 0.6827, accuracy: 0.01)
    }
    
    func test_Normal_Between_TwoSigma() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(dist.between(-2.0, 2.0), 0.9545, accuracy: 0.01)
    }
    
    // MARK: - Normal Distribution Inverse CDF Tests
    
    func test_Normal_InverseCDF_0_5_ReturnsZero() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(try dist.inverseCdf(0.5), 0.0, accuracy: 0.001)
    }
    
    func test_Normal_InverseCDF_0_975_Returns196() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(try dist.inverseCdf(0.975), 1.96, accuracy: 0.01)
    }
    
    func test_Normal_InverseCDF_0_025_ReturnsNegative196() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        XCTAssertEqual(try dist.inverseCdf(0.025), -1.96, accuracy: 0.01)
    }
    
    func test_Normal_InverseCDF_NonStandard() throws {
        let dist = try NormalDistribution(mean: 100, stdDev: 15)
        XCTAssertEqual(try dist.inverseCdf(0.5), 100.0, accuracy: 0.01)
    }
    
    func test_Normal_InverseCDF_InvalidP_ThrowsError() throws {
        let dist = try NormalDistribution(mean: 0, stdDev: 1)
        
        XCTAssertThrowsError(try dist.inverseCdf(0.0)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
        
        XCTAssertThrowsError(try dist.inverseCdf(1.0)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Normal Distribution Initialization Tests
    
    func test_Normal_InvalidStdDev_ThrowsError() {
        XCTAssertThrowsError(try NormalDistribution(mean: 0, stdDev: 0)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
        
        XCTAssertThrowsError(try NormalDistribution(mean: 0, stdDev: -1)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Normal_StandardDistribution_Exists() {
        let standard = NormalDistribution.standard
        XCTAssertEqual(standard.mean, 0.0, accuracy: 1e-15)
        XCTAssertEqual(standard.stdDev, 1.0, accuracy: 1e-15)
    }
    
    // MARK: - Normal Distribution Z-Score Tests
    
    func test_Normal_ZScore_Calculation() throws {
        let dist = try NormalDistribution(mean: 100, stdDev: 15)
        XCTAssertEqual(dist.zScore(115), 1.0, accuracy: 1e-15)
        XCTAssertEqual(dist.zScore(85), -1.0, accuracy: 1e-15)
        XCTAssertEqual(dist.zScore(100), 0.0, accuracy: 1e-15)
    }
    
    func test_Normal_FromZScore_Calculation() throws {
        let dist = try NormalDistribution(mean: 100, stdDev: 15)
        XCTAssertEqual(dist.fromZScore(1.0), 115.0, accuracy: 1e-15)
        XCTAssertEqual(dist.fromZScore(-1.0), 85.0, accuracy: 1e-15)
        XCTAssertEqual(dist.fromZScore(0.0), 100.0, accuracy: 1e-15)
    }
    
    // MARK: - Binomial Distribution PMF Tests
    
    func test_Binomial_PMF_FairCoin_5Heads() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.5)
        XCTAssertEqual(try dist.pmf(5), 0.246, accuracy: 0.001)
    }
    
    func test_Binomial_PMF_AtZero() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.5)
        let expected = pow(0.5, 10)
        XCTAssertEqual(try dist.pmf(0), expected, accuracy: 0.0001)
    }
    
    func test_Binomial_PMF_AtN() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.5)
        let expected = pow(0.5, 10)
        XCTAssertEqual(try dist.pmf(10), expected, accuracy: 0.0001)
    }
    
    func test_Binomial_PMF_P0_K0_Returns1() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0)
        XCTAssertEqual(try dist.pmf(0), 1.0, accuracy: 1e-15)
    }
    
    func test_Binomial_PMF_P1_KN_Returns1() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 1)
        XCTAssertEqual(try dist.pmf(10), 1.0, accuracy: 1e-15)
    }
    
    func test_Binomial_PMF_KGreaterThanN_ThrowsError() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.5)
        
        XCTAssertThrowsError(try dist.pmf(11)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Binomial_PMF_NegativeK_ThrowsError() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.5)
        
        XCTAssertThrowsError(try dist.pmf(-1)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Binomial Distribution CDF Tests
    
    func test_Binomial_CDF_AtMost5() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.5)
        XCTAssertEqual(try dist.cdf(5), 0.623, accuracy: 0.001)
    }
    
    func test_Binomial_CDF_AtMost0() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.5)
        let expected = pow(0.5, 10)
        XCTAssertEqual(try dist.cdf(0), expected, accuracy: 0.0001)
    }
    
    func test_Binomial_CDF_AtMostN_Returns1() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.5)
        XCTAssertEqual(try dist.cdf(10), 1.0, accuracy: 0.001)
    }
    
    // MARK: - Binomial Distribution Upper CDF Tests
    
    func test_Binomial_UpperCDF_AtLeast5() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.5)
        let cdf4 = try dist.cdf(4)
        XCTAssertEqual(try dist.upperCdf(5), 1.0 - cdf4, accuracy: 0.001)
    }
    
    func test_Binomial_UpperCDF_AtLeast0_Returns1() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.5)
        XCTAssertEqual(try dist.upperCdf(0), 1.0, accuracy: 1e-15)
    }
    
    // MARK: - Binomial Distribution Between Tests
    
    func test_Binomial_Between_ReturnsCorrect() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.5)
        let expected = try dist.cdf(7) - dist.cdf(2)
        XCTAssertEqual(try dist.between(3, 7), expected, accuracy: 0.001)
    }
    
    // MARK: - Binomial Distribution Initialization Tests
    
    func test_Binomial_InvalidProbability_ThrowsError() {
        XCTAssertThrowsError(try BinomialDistribution(trials: 10, probability: 1.5)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
        
        XCTAssertThrowsError(try BinomialDistribution(trials: 10, probability: -0.1)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    func test_Binomial_InvalidTrials_ThrowsError() {
        XCTAssertThrowsError(try BinomialDistribution(trials: 0, probability: 0.5)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
        
        XCTAssertThrowsError(try BinomialDistribution(trials: -1, probability: 0.5)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Binomial Distribution Properties Tests
    
    func test_Binomial_Mean_Calculation() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.3)
        XCTAssertEqual(dist.mean, 3.0, accuracy: 1e-15)
    }
    
    func test_Binomial_Variance_Calculation() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.3)
        XCTAssertEqual(dist.variance, 2.1, accuracy: 1e-15)
    }
    
    func test_Binomial_StdDev_Calculation() throws {
        let dist = try BinomialDistribution(trials: 10, probability: 0.3)
        XCTAssertEqual(dist.stdDev, sqrt(2.1), accuracy: 1e-15)
    }
    
    // MARK: - Poisson Distribution PMF Tests
    
    func test_Poisson_PMF_Lambda5_K5() throws {
        let dist = try PoissonDistribution(lambda: 5)
        XCTAssertEqual(try dist.pmf(5), 0.175, accuracy: 0.001)
    }
    
    func test_Poisson_PMF_K0() throws {
        let dist = try PoissonDistribution(lambda: 2)
        XCTAssertEqual(try dist.pmf(0), exp(-2), accuracy: 0.001)
    }
    
    func test_Poisson_PMF_K1() throws {
        let dist = try PoissonDistribution(lambda: 3)
        XCTAssertEqual(try dist.pmf(1), 3 * exp(-3), accuracy: 0.001)
    }
    
    func test_Poisson_PMF_NegativeK_ThrowsError() throws {
        let dist = try PoissonDistribution(lambda: 5)
        
        XCTAssertThrowsError(try dist.pmf(-1)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Poisson Distribution CDF Tests
    
    func test_Poisson_CDF_Lambda5_K5() throws {
        let dist = try PoissonDistribution(lambda: 5)
        XCTAssertEqual(try dist.cdf(5), 0.616, accuracy: 0.01)
    }
    
    func test_Poisson_CDF_K0() throws {
        let dist = try PoissonDistribution(lambda: 2)
        XCTAssertEqual(try dist.cdf(0), exp(-2), accuracy: 0.001)
    }
    
    // MARK: - Poisson Distribution Upper CDF Tests
    
    func test_Poisson_UpperCDF_AtLeast3() throws {
        let dist = try PoissonDistribution(lambda: 5)
        let cdf2 = try dist.cdf(2)
        XCTAssertEqual(try dist.upperCdf(3), 1.0 - cdf2, accuracy: 0.001)
    }
    
    // MARK: - Poisson Distribution Between Tests
    
    func test_Poisson_Between_ReturnsCorrect() throws {
        let dist = try PoissonDistribution(lambda: 5)
        let expected = try dist.cdf(7) - dist.cdf(2)
        XCTAssertEqual(try dist.between(3, 7), expected, accuracy: 0.001)
    }
    
    // MARK: - Poisson Distribution Initialization Tests
    
    func test_Poisson_InvalidLambda_ThrowsError() {
        XCTAssertThrowsError(try PoissonDistribution(lambda: 0)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
        
        XCTAssertThrowsError(try PoissonDistribution(lambda: -1)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Poisson Distribution Properties Tests
    
    func test_Poisson_Mean_Calculation() throws {
        let dist = try PoissonDistribution(lambda: 7.5)
        XCTAssertEqual(dist.mean, 7.5, accuracy: 1e-15)
    }
    
    func test_Poisson_Variance_Calculation() throws {
        let dist = try PoissonDistribution(lambda: 7.5)
        XCTAssertEqual(dist.variance, 7.5, accuracy: 1e-15)
    }
    
    func test_Poisson_StdDev_Calculation() throws {
        let dist = try PoissonDistribution(lambda: 7.5)
        XCTAssertEqual(dist.stdDev, sqrt(7.5), accuracy: 1e-15)
    }
    
    // MARK: - Error Function Tests
    
    func test_Erf_Zero_ReturnsZero() {
        XCTAssertEqual(Distributions.erf(0), 0.0, accuracy: 0.001)
    }
    
    func test_Erf_One_ReturnsCorrect() {
        XCTAssertEqual(Distributions.erf(1), 0.8427, accuracy: 0.001)
    }
    
    func test_Erf_Large_ReturnsNearOne() {
        XCTAssertEqual(Distributions.erf(3), 0.9999, accuracy: 0.001)
    }
    
    func test_Erf_Negative_ReturnsNegative() {
        XCTAssertEqual(Distributions.erf(-1), -Distributions.erf(1), accuracy: 0.001)
    }
    
    func test_Erf_Symmetry() {
        XCTAssertEqual(Distributions.erf(2.5), -Distributions.erf(-2.5), accuracy: 1e-10)
    }
    
    // MARK: - Complementary Error Function Tests
    
    func test_Erfc_Zero_ReturnsOne() {
        XCTAssertEqual(Distributions.erfc(0), 1.0, accuracy: 0.001)
    }
    
    func test_Erfc_Large_ReturnsNearZero() {
        XCTAssertEqual(Distributions.erfc(3), 1.0 - Distributions.erf(3), accuracy: 0.001)
    }
    
    // MARK: - Standard Normal CDF Tests
    
    func test_StandardNormalCDF_AtZero() {
        XCTAssertEqual(Distributions.standardNormalCdf(0), 0.5, accuracy: 0.001)
    }
    
    func test_StandardNormalCDF_At1() {
        XCTAssertEqual(Distributions.standardNormalCdf(1), 0.8413, accuracy: 0.001)
    }
    
    func test_StandardNormalCDF_AtNegative1() {
        XCTAssertEqual(Distributions.standardNormalCdf(-1), 0.1587, accuracy: 0.001)
    }
    
    // MARK: - Standard Normal Inverse CDF Tests
    
    func test_StandardNormalInverseCDF_0_5_ReturnsZero() throws {
        XCTAssertEqual(try Distributions.standardNormalInverseCdf(0.5), 0.0, accuracy: 0.001)
    }
    
    func test_StandardNormalInverseCDF_0_8413_Returns1() throws {
        XCTAssertEqual(try Distributions.standardNormalInverseCdf(0.8413), 1.0, accuracy: 0.01)
    }
    
    func test_StandardNormalInverseCDF_InvalidP_ThrowsError() {
        XCTAssertThrowsError(try Distributions.standardNormalInverseCdf(0.0)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
        
        XCTAssertThrowsError(try Distributions.standardNormalInverseCdf(1.0)) { error in
            guard case CalculatorError.invalidInput = error else {
                XCTFail("Expected invalidInput error")
                return
            }
        }
    }
    
    // MARK: - Gamma Function Tests
    
    func test_Gamma_Integers() throws {
        XCTAssertEqual(try Distributions.gamma(1), 1.0, accuracy: 0.001)
        XCTAssertEqual(try Distributions.gamma(2), 1.0, accuracy: 0.001)
        XCTAssertEqual(try Distributions.gamma(3), 2.0, accuracy: 0.001)
        XCTAssertEqual(try Distributions.gamma(4), 6.0, accuracy: 0.001)
        XCTAssertEqual(try Distributions.gamma(5), 24.0, accuracy: 0.001)
    }
    
    func test_Gamma_Half() throws {
        XCTAssertEqual(try Distributions.gamma(0.5), sqrt(Double.pi), accuracy: 0.001)
    }
    
    // MARK: - Log Gamma Tests
    
    func test_LogGamma_MatchesLogOfGamma() throws {
        let x = 5.0
        let logGamma = try Distributions.logGamma(x)
        let gamma = try Distributions.gamma(x)
        XCTAssertEqual(logGamma, log(gamma), accuracy: 0.001)
    }
    
    func test_LogGamma_LargeValue_DoesNotOverflow() throws {
        let result = try Distributions.logGamma(100)
        XCTAssertTrue(result.isFinite)
    }
    
    // MARK: - Regularized Gamma Tests
    
    func test_RegularizedGammaP_AtZero() throws {
        let result = try Distributions.regularizedGammaP(2.0, 0.0)
        XCTAssertEqual(result, 0.0, accuracy: 1e-15)
    }
    
    func test_RegularizedGammaQ_AtZero() throws {
        let result = try Distributions.regularizedGammaQ(2.0, 0.0)
        XCTAssertEqual(result, 1.0, accuracy: 1e-15)
    }
    
    func test_RegularizedGamma_PplusQ_Equals1() throws {
        let a = 3.0
        let x = 2.0
        let p = try Distributions.regularizedGammaP(a, x)
        let q = try Distributions.regularizedGammaQ(a, x)
        XCTAssertEqual(p + q, 1.0, accuracy: 0.001)
    }
}
