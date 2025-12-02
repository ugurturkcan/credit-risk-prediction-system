import 'package:flutter/material.dart';
import '../models/risk_models.dart';
import '../services/api_service.dart';

class RiskHomePage extends StatefulWidget {
  const RiskHomePage({super.key});

  @override
  State<RiskHomePage> createState() => _RiskHomePageState();
}

class _RiskHomePageState extends State<RiskHomePage> {
  // Kontrolcüler
  final _incomeController = TextEditingController();
  final _creditController = TextEditingController();
  final _ageController = TextEditingController();
  final _experienceController = TextEditingController();

  // Değişkenler
  String _education = "Lise";
  final List<String> _educationLevels = ["İlköğretim", "Lise", "Üniversite", "Yüksek Lisans", "Doktora"];
  bool _isMarried = false;
  int _creditTerm = 24;
  final List<int> _terms = [12, 24, 36, 48, 60];
  double _kkbScore = 0.5;

  // Durum
  bool _isLoading = false;
  RiskResponse? _resultData;

  // --- İŞ MANTIĞI (Sadece Servisi Çağırır) ---
  Future<void> _analyze() async {
    setState(() { _isLoading = true; _resultData = null; });

    try {
      // Veriyi Hazırla (Model Kullanarak)
      final request = RiskRequest(
        income: double.tryParse(_incomeController.text) ?? 0,
        creditAmount: double.tryParse(_creditController.text) ?? 0,
        age: int.tryParse(_ageController.text) ?? 0,
        education: _education,
        yearsEmployed: double.tryParse(_experienceController.text) ?? 0,
        isMarried: _isMarried,
        creditTerm: _creditTerm,
        extScoreGuess: _kkbScore,
      );

      // Servise Gönder
      final response = await ApiService.predictRisk(request);

      setState(() { _resultData = response; });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kredi Risk Skoru Tahminleyicisi")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Form Alanları (Basitleştirildi)
            _buildCard("Kişisel Bilgiler", [
              Row(children: [Expanded(child: _buildText("Yaş", _ageController)), const SizedBox(width: 10), Expanded(child: _buildText("Kıdem", _experienceController))]),
              const SizedBox(height: 10),
              _buildDropdown("Eğitim", _educationLevels, _education, (v) => setState(() => _education = v!)),
              SwitchListTile(title: const Text("Evli misiniz?"), value: _isMarried, onChanged: (v) => setState(() => _isMarried = v), activeColor: const Color(0xFF0D47A1)),
            ]),
            const SizedBox(height: 20),
            _buildCard("Finansal Bilgiler", [
              _buildText("Aylık Gelir (TL)", _incomeController),
              const SizedBox(height: 10),
              _buildText("İstenen Kredi (TL)", _creditController),
              const SizedBox(height: 10),
              _buildDropdown("Vade (Ay)", _terms.map((e)=>e.toString()).toList(), _creditTerm.toString(), (v) => setState(() => _creditTerm = int.parse(v!))),
              const SizedBox(height: 10),
              const Text("Kredi Notu Tahmini"),
              Slider(value: _kkbScore, min: 0.1, max: 0.9, onChanged: (v) => setState(() => _kkbScore = v), activeColor: const Color(0xFF0D47A1)),
            ]),
            const SizedBox(height: 30),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
              onPressed: _isLoading ? null : _analyze,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("ANALİZ ET", style: TextStyle(fontSize: 18)),
            )),
            if (_resultData != null) _buildResult(),
          ],
        ),
      ),
    );
  }

  // --- UI YARDIMCILARI ---
  Widget _buildCard(String title, List<Widget> children) {
    return Card(elevation: 3, color: Colors.white, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))), const Divider(), ...children])));
  }
  Widget _buildText(String label, TextEditingController c) => TextField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true));
  Widget _buildDropdown(String label, List<String> items, String val, Function(String?) changed) => DropdownButtonFormField(value: val, items: items.map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: changed, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));
  
 // --- SONUÇ KARTI (GÜNCELLENMİŞ: SKOR ÇUBUĞU İLE) ---
  Widget _buildResult() {
    bool success = _resultData!.status == "APPROVE";
    Color statusColor = success ? Colors.green : Colors.red;
    int score = _resultData!.creditScore;
    
    // Skora göre renk belirle (Dinamik Renk)
    Color scoreColor = Colors.red;
    String riskLevelText = "Çok Riskli";
    
    if (score > 500) { scoreColor = Colors.orange; riskLevelText = "Orta Riskli"; }
    if (score > 700) { scoreColor = Colors.green; riskLevelText = "Güvenilir"; }
    if (score > 850) { scoreColor = const Color(0xFF0D47A1); riskLevelText = "Mükemmel"; }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          // 1. Durum İkonu ve Yazısı
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(success ? Icons.check_circle : Icons.cancel, color: statusColor, size: 32),
              const SizedBox(width: 10),
              Text(
                success ? "KREDİ ONAYLANDI" : "REDDEDİLDİ",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: statusColor),
              ),
            ],
          ),
          
          if (!success) 
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_resultData!.reason, style: TextStyle(color: Colors.grey[700])),
            ),

          const Divider(height: 40),

          // 2. YENİ SKOR ÇUBUĞU ALANI
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("AI Güven Skoru", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  Text("$score / 1000", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: scoreColor)),
                ],
              ),
              const SizedBox(height: 10),
              
              // İlerleme Çubuğu
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: score / 1000, // 0.0 ile 1.0 arası değer ister
                  minHeight: 15,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              
              const SizedBox(height: 5),
              
              // Alt Etiketler (0 ve 1000)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("0", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(riskLevelText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: scoreColor)),
                  const Text("1000", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 25),

          // 3. Taksit Bilgisi
          if (_resultData!.monthlyInstallment > 0)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tahmini Taksit:", style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.w600)),
                  Text("${_resultData!.monthlyInstallment} TL", style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          // 4. Akıllı Öneri (Varsa)
          if (_resultData!.suggestion != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_resultData!.suggestion!, style: const TextStyle(fontSize: 13, color: Colors.black87))),
                ],
              ),
            ),
          ],
          
          // 5. Banka Teklifleri (Varsa)
          if (_resultData!.offers.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text("Sizin İçin Teklifler", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            ..._resultData!.offers.map((o) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              color: Colors.grey[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
              child: ListTile(
                leading: const Icon(Icons.account_balance, color: Color(0xFF0D47A1)),
                title: Text(o.bank, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Faiz: %${o.rate}"),
                trailing: Text("${o.monthlyPayment} TL", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            )).toList()
          ]
        ],
      ),
    );
  }
}