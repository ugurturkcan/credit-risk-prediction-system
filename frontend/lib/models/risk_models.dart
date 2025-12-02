// lib/models/risk_models.dart

// --- İSTEK MODELİ (Giden Veri) ---
class RiskRequest {
  final double income;
  final double creditAmount;
  final int age;
  final String education;
  final double yearsEmployed;
  final bool isMarried;
  final int creditTerm;
  final double extScoreGuess;

  RiskRequest({
    required this.income,
    required this.creditAmount,
    required this.age,
    required this.education,
    required this.yearsEmployed,
    required this.isMarried,
    required this.creditTerm,
    required this.extScoreGuess,
  });

  Map<String, dynamic> toJson() {
    return {
      "income": income,
      "credit_amount": creditAmount,
      "age": age,
      "education": education,
      "years_employed": yearsEmployed,
      "is_married": isMarried,
      "credit_term": creditTerm,
      "ext_score_guess": extScoreGuess,
    };
  }
}

// --- CEVAP MODELİ (Gelen Veri) ---
class RiskResponse {
  final String status;
  final int creditScore;
  final double riskProbability;
  final int monthlyInstallment;
  final String reason;
  final String? suggestion; // Akıllı Öneri (Opsiyonel)
  final List<BankOffer> offers; // Banka Teklifleri (Liste)

  RiskResponse({
    required this.status,
    required this.creditScore,
    required this.riskProbability,
    required this.monthlyInstallment,
    required this.reason,
    this.suggestion,
    required this.offers,
  });

  factory RiskResponse.fromJson(Map<String, dynamic> json) {
    // Gelen JSON içindeki 'offers' listesini BankOffer nesnelerine çevir
    var list = json['offers'] as List? ?? [];
    List<BankOffer> offerList = list.map((i) => BankOffer.fromJson(i)).toList();

    return RiskResponse(
      status: json['status'] ?? "ERROR",
      creditScore: json['credit_score'] ?? 0,
      riskProbability: json['risk_probability'] ?? 0.0,
      monthlyInstallment: json['monthly_installment'] ?? 0,
      reason: json['reason'] ?? "",
      suggestion: json['suggestion'],
      offers: offerList,
    );
  }
}

// --- YENİ: BANKA TEKLİFİ MODELİ ---
class BankOffer {
  final String bank;
  final double rate;
  final int monthlyPayment;

  BankOffer({
    required this.bank, 
    required this.rate, 
    required this.monthlyPayment
  });

  factory BankOffer.fromJson(Map<String, dynamic> json) {
    return BankOffer(
      bank: json['bank'] ?? "Bilinmeyen Banka",
      rate: (json['rate'] ?? 0.0).toDouble(),
      monthlyPayment: json['monthly_payment'] ?? 0,
    );
  }
}