import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/reminder.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class RemindersView extends StatefulWidget {
  const RemindersView({super.key});

  @override
  State<RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends State<RemindersView> {
  ReminderType? _selectedTypeFilter;

  @override
  Widget build(BuildContext context) {
    return Consumer<CrmProvider>(
      builder: (context, provider, child) {
        final reminders = provider.reminders.where((r) {
          return _selectedTypeFilter == null || r.type == _selectedTypeFilter;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hatırlatmalar & Randevular', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_alarm, color: AppTheme.emeraldAccent),
                onPressed: () => _showAddReminderModal(context, provider),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Filter Chips
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('Tümü', _selectedTypeFilter == null, () => setState(() => _selectedTypeFilter = null)),
                      _buildChip('Yer Gösterme', _selectedTypeFilter == ReminderType.yerGosterme, () => setState(() => _selectedTypeFilter = ReminderType.yerGosterme)),
                      _buildChip('Geri Arama', _selectedTypeFilter == ReminderType.geriArama, () => setState(() => _selectedTypeFilter = ReminderType.geriArama)),
                      _buildChip('Tapu Randevusu', _selectedTypeFilter == ReminderType.tapuRandevusu, () => setState(() => _selectedTypeFilter = ReminderType.tapuRandevusu)),
                    ],
                  ),
                ),
              ),

              // Reminders list
              Expanded(
                child: reminders.isEmpty
                    ? const Center(child: Text('Hatırlatma bulunmuyor.', style: TextStyle(color: AppTheme.textSecondaryDark)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: reminders.length,
                        itemBuilder: (context, index) {
                          final rem = reminders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: IconButton(
                                icon: Icon(
                                  rem.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: rem.isCompleted ? AppTheme.successGreen : AppTheme.emeraldAccent,
                                  size: 24,
                                ),
                                onPressed: () => provider.toggleReminder(rem.id),
                              ),
                              title: Text(
                                rem.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: rem.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${Formatters.formatDateTime(rem.dateTime)} • ${rem.typeName}',
                                    style: const TextStyle(color: AppTheme.emeraldAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  if (rem.note.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(rem.note, style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                                  ],
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 20),
                                onPressed: () => provider.deleteReminder(rem.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.emeraldPrimary,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddReminderModal(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.emeraldPrimary,
        backgroundColor: AppTheme.darkCard,
        labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textSecondaryDark),
      ),
    );
  }

  void _showAddReminderModal(BuildContext context, CrmProvider provider) {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 2));
    ReminderType selectedType = ReminderType.yerGosterme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Yeni Randevu / Hatırlatma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Başlık', hintText: 'Bebek villa yer gösterme randevusu'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ReminderType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: 'Hatırlatma Türü'),
                    items: ReminderType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(Reminder(id: '', title: '', dateTime: DateTime.now(), type: t).typeName),
                      );
                    }).toList(),
                    onChanged: (val) => setModalState(() => selectedType = val!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(labelText: 'Notlar'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tarih & Saat: ${Formatters.formatDateTime(selectedDate)}',
                        style: const TextStyle(color: AppTheme.emeraldAccent, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today, color: AppTheme.goldAccent),
                        label: const Text('Değiştir', style: TextStyle(color: AppTheme.goldAccent)),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDate),
                            );
                            if (time != null) {
                              setModalState(() {
                                selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldPrimary),
                      onPressed: () {
                        if (titleCtrl.text.isNotEmpty) {
                          provider.addReminder(
                            Reminder(
                              id: const Uuid().v4(),
                              title: titleCtrl.text,
                              note: noteCtrl.text,
                              dateTime: selectedDate,
                              type: selectedType,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
