import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'provider_model.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  final Map<String, List<Map<String, String>>> providersData;

  const ProviderRegistrationScreen({super.key, required this.providersData});

  @override
  State<ProviderRegistrationScreen> createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState extends State<ProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name, _category, _experience, _phone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Become a Provider"),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter your name" : null,
                onSaved: (value) => _name = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Category (e.g., Plumber)"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter a category" : null,
                onSaved: (value) => _category = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Years of Experience"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Please enter your experience" : null,
                onSaved: (value) => _experience = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? "Please enter your phone number" : null,
                onSaved: (value) => _phone = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final box = Hive.box<ProviderModel>('providers');

                      final newProvider = ProviderModel(
                        name: _name!,
                        service: _category!,
                        exp: "$_experience years",
                        phone: _phone!,
                        totalRating: 4.0,
                        ratingCount: 1,
                      );

                      await box.add(newProvider);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Provider Registered Successfully")),
                      );
                      Navigator.pop(context);
                    }
                  },
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
