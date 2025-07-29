import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();

  // Variables de campos de texto
  String cliente = '';
  String contacto = '';
  String tecnico = '';
  TimeOfDay? horaLlegada;
  TimeOfDay? horaSalida;
  String descripcion = '';
  String comentarios = '';

  // Controlador de firma
  final SignatureController _firmaController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // Selección de hora
  Future<void> seleccionarHora(bool esLlegada) async {
    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (horaSeleccionada != null) {
      setState(() {
        if (esLlegada) {
          horaLlegada = horaSeleccionada;
        } else {
          horaSalida = horaSeleccionada;
        }
      });
    }
  }

  // Acción al guardar formulario
  void guardarFormulario() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // (Opcional) Exportar firma
      final firmaBytes = await _firmaController.toPngBytes();

      // Mostrar confirmación
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Formulario guardado'),
          content: Text(
            'Cliente: $cliente\nTécnico: $tecnico\nFirma: ${firmaBytes != null ? '✔' : '❌'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _firmaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario de Mantenimiento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Datos generales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cliente'),
                onSaved: (value) => cliente = value ?? '',
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contacto'),
                onSaved: (value) => contacto = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Técnico'),
                onSaved: (value) => tecnico = value ?? '',
              ),
              const SizedBox(height: 16),
              const Text(
                'Horas de trabajo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => seleccionarHora(true),
                      child: Text(
                        horaLlegada == null
                            ? 'Hora llegada'
                            : 'Llegó: ${horaLlegada!.format(context)}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => seleccionarHora(false),
                      child: Text(
                        horaSalida == null
                            ? 'Hora salida'
                            : 'Salió: ${horaSalida!.format(context)}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Descripción del trabajo',
                ),
                maxLines: 3,
                onSaved: (value) => descripcion = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Comentarios'),
                maxLines: 2,
                onSaved: (value) => comentarios = value ?? '',
              ),
              const SizedBox(height: 20),

              // Firma digital
              const Text(
                'Firma del técnico o cliente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Signature(
                  controller: _firmaController,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _firmaController.clear(),
                    icon: const Icon(Icons.delete),
                    label: const Text('Borrar firma'),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: guardarFormulario,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
