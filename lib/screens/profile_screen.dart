import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/index.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  Gender? _selectedGender;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              if (provider.userProfile != null) {
                return IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: _toggleEdit,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.userProfile == null && !_isEditing) {
            return _buildEmptyProfile();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(provider.userProfile),

                  const SizedBox(height: 24),

                  if (_isEditing) ...[
                    _buildEditForm(provider.userProfile),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ] else ...[
                    _buildProfileInfo(provider.userProfile),
                    const SizedBox(height: 24),
                    _buildStatistics(provider),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No profile found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your profile to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _toggleEdit,
            icon: const Icon(Icons.add),
            label: const Text('Create Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile? profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                profile?.name.isNotEmpty == true
                    ? profile!.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.name ?? 'No name set',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profile?.age != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${profile!.age} years old',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (profile?.gender != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile!.gender.toString().split('.').last,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(UserProfile? existingProfile) {
    if (existingProfile != null) {
      _nameController.text = existingProfile.name;
      _ageController.text = existingProfile.age?.toString() ?? '';
      _selectedGender = existingProfile.gender;
    }

    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Gender>(
          value: _selectedGender,
          decoration: const InputDecoration(
            labelText: 'Gender',
            prefixIcon: Icon(Icons.people),
          ),
          items: Gender.values.map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(gender.toString().split('.').last),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ageController,
          decoration: const InputDecoration(
            labelText: 'Age',
            hintText: 'Enter your age',
            prefixIcon: Icon(Icons.calendar_today),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final age = int.tryParse(value);
              if (age == null || age < 1 || age > 150) {
                return 'Please enter a valid age';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save),
            label: const Text('Save Profile'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _cancelEdit,
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(UserProfile? profile) {
    return Column(
      children: [
        _buildInfoCard(
          icon: Icons.person,
          title: 'Name',
          value: profile?.name ?? 'Not set',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.people,
          title: 'Gender',
          value: profile?.gender?.toString().split('.').last ?? 'Not set',
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.calendar_today,
          title: 'Age',
          value: profile?.age?.toString() ?? 'Not set',
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildStatistics(AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Total Readings',
          value: provider.readings.length.toString(),
          icon: Icons.favorite,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'First Reading',
          value: provider.readings.isEmpty
              ? 'None'
              : provider.readings.last.formattedDate,
          icon: Icons.start,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Latest Reading',
          value: provider.getLatestReading()?.formattedDate ?? 'None',
          icon: Icons.update,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final name = _nameController.text.trim();
    final age = _ageController.text.isEmpty ? null : int.parse(_ageController.text);

    final profile = UserProfile(
      id: provider.userProfile?.id,
      name: name,
      gender: _selectedGender,
      age: age,
      createdAt: provider.userProfile?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await provider.saveUserProfile(profile);

    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
    }
  }

  void _cancelEdit() {
    _nameController.clear();
    _ageController.clear();
    _selectedGender = null;
    setState(() {
      _isEditing = false;
    });
  }
}
