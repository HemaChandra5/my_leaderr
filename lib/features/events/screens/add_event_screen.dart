import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/event_model.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  EventCategory _category = EventCategory.local;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  bool _isFree = true;
  bool _isOnline = false;

  @override
  void dispose() {
    _titleController.dispose();
    _organizerController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _date,
    );
    if (picked == null) {
      return;
    }
    setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) {
      return;
    }
    setState(() => _time = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String amPm = _time.period == DayPeriod.am ? 'AM' : 'PM';
    final int hour = _time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod;
    final String minute = _time.minute.toString().padLeft(2, '0');

    final EventModel created = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1400&q=80',
      category: _category,
      date: _date,
      time: '$hour:$minute $amPm',
      location: _locationController.text.trim(),
      organizer: _organizerController.text.trim(),
      interestedCount: 0,
      status: EventStatus.upcoming,
      isFree: _isFree,
      isOnline: _isOnline,
      tags: <EventFilterTag>{
        _isFree ? EventFilterTag.free : EventFilterTag.paid,
        _isOnline ? EventFilterTag.online : EventFilterTag.offline,
        EventFilterTag.leadership,
      },
    );

    Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Add Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _field(_titleController, 'Event Title'),
              const SizedBox(height: 10),
              _field(_organizerController, 'Organizer Name'),
              const SizedBox(height: 10),
              _field(_locationController, 'Location'),
              const SizedBox(height: 10),
              _field(_descriptionController, 'Description', maxLines: 4),
              const SizedBox(height: 12),
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: EventCategory.values
                    .map(
                      (EventCategory category) => DropdownMenuItem<EventCategory>(
                        value: category,
                        child: Text(category.label),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (EventCategory? value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text('${_date.day}/${_date.month}/${_date.year}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.schedule_rounded),
                      label: Text(_time.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                value: _isFree,
                onChanged: (bool value) => setState(() => _isFree = value),
                title: const Text('Free Event'),
              ),
              SwitchListTile.adaptive(
                value: _isOnline,
                onChanged: (bool value) => setState(() => _isOnline = value),
                title: const Text('Online Event'),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        return null;
      },
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label),
    );
  }
}
