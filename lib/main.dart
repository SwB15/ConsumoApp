import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const CalculadoraConsumoApp());
}

class CalculadoraConsumoApp extends StatelessWidget {
  const CalculadoraConsumoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Consumo',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const ConsumoHomePage(title: 'Calculadora de Consumo'),
    );
  }
}

class ConsumoHomePage extends StatefulWidget {
  const ConsumoHomePage({super.key, required this.title});
  final String title;
  @override
  State<ConsumoHomePage> createState() => _ConsumoPageState();
}

class _ConsumoPageState extends State<ConsumoHomePage> {
  final TextEditingController potenciaController = TextEditingController();
  final TextEditingController precioController = TextEditingController(
    text: '435.51',
  );
  final TextEditingController diasMesController = TextEditingController(
    text: '30',
  );
  final TextEditingController diasAnoController = TextEditingController(
    text: '365',
  );

  double? costoHora;
  double? costoDia;
  double? costoMes;
  double? costoAno;
  String? errorMensaje;

  String costoHoraGs = '';
  String costoDiaGs = '';
  String costoMesGs = '';
  String costoAnoGs = '';

  final NumberFormat formatoGs = NumberFormat.currency(
    locale: 'es_PY',
    symbol: 'Gs ',
    decimalDigits: 2,
  );

  final formatoGsSinDecimales = NumberFormat.currency(
    locale: 'es_PY',
    symbol: 'Gs.',
    decimalDigits: 0,
  );

  void calcularCostos() {
    setState(() {
      errorMensaje = null;
      costoHora = costoDia = costoMes = costoAno = null;

      double? potenciaW = double.tryParse(
        potenciaController.text.replaceAll(',', '.'),
      );
      double? precioKwh = double.tryParse(
        precioController.text.replaceAll(',', '.'),
      );

      int? diasMes = int.tryParse(diasMesController.text);
      int? diasAno = int.tryParse(diasAnoController.text);

      if (potenciaW == null || potenciaW < 0) {
        errorMensaje = 'Ingresa una potencia válida (en Watts)';
        return;
      }

      if (diasMes == null || diasMes <= 0) {
        errorMensaje = 'Ingresa un número válido para los días del mes';
        return;
      }

      if (diasAno == null || diasAno <= 0) {
        errorMensaje = 'Ingresa un número válido para los días del año';
        return;
      }

      //Energia por hora en Kwh
      double energiaHora = potenciaW / 1000.0; //Kwh en 1 hora
      costoHora = (energiaHora ?? 0) * (precioKwh ?? 0);

      //Por dia
      costoDia = costoHora! * 24.0;

      //Por mes
      costoMes = costoDia! * diasMes;

      //Por año
      costoAno = costoDia! * diasAno;

      costoHoraGs = formatoGsSinDecimales.format(costoHora!.roundToDouble());
      costoDiaGs = formatoGsSinDecimales.format(costoDia!.roundToDouble());
      costoMesGs = formatoGsSinDecimales.format(costoMes!.roundToDouble());
      costoAnoGs = formatoGsSinDecimales.format(costoAno!.roundToDouble());
    });
  }

  @override
  void dispose() {
    potenciaController.dispose();
    precioController.dispose();
    diasMesController.dispose();
    diasAnoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calculadora de Consumo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Potencia del electrodoméstico (W):',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: potenciaController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: 100, 1500, 2000',
              ),
              onSubmitted: (_) => calcularCostos(),
            ),
            const SizedBox(height: 16),
            Text(
              'Precio residencial (Gs*Kwh):',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: 435.51',
              ),
              onSubmitted: (_) => calcularCostos(),
            ),
            const SizedBox(height: 16),
            Text('Días considerados por mes:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            TextField(
              controller: diasMesController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: 30',
              ),
              onSubmitted: (_) => calcularCostos(),
            ),
            const SizedBox(height: 16),
            Text('Días considerados por año:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            TextField(
              controller: diasAnoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: 365',
              ),
              onSubmitted: (_) => calcularCostos(),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: calcularCostos,
                child: Text('Calcular'),
              ),
            ),
            const SizedBox(height: 24),
            if (errorMensaje != null) ...[
              Text(errorMensaje!, style: TextStyle(color: Colors.red)),
            ] else if (costoHora != null) ...[
              Text(
                'Resultados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              buildResultadosRow('Costo por hora: ', costoHoraGs),
              const SizedBox(height: 4),
              buildResultadosRow('Costo por día:', costoDiaGs),
              const SizedBox(height: 4),
              buildResultadosRow(
                'Costo por ${diasMesController.text} días:',
                costoMesGs,
              ),
              const SizedBox(height: 4),
              buildResultadosRow(
                'Costo por ${diasAnoController.text} días:',
                costoAnoGs,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildResultadosRow(String etiqueta, String valorFormateado) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(etiqueta, style: TextStyle(fontSize: 16))),
        Text(
          valorFormateado,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
