import 'package:flutter/material.dart';

// Model class untuk Task = blueprint/template untuk objek Task
class Task {
  // Property untuk menyimpan judul task
  String title;
  // Property untuk menyimpan status selesai/belum
  bool isCompleted;

  // Constructor = function untuk membuat Task baru
  Task({
    // title wajib diisi (required)
    required this.title,
    // isCompleted opsional, default false (belum selesai)
    this.isCompleted = false,
  });

  // Method untuk toggle status completed (true ↔ false)
  void toggle() {
    // Flip boolean: true jadi false, false jadi true
    isCompleted = !isCompleted;
  }

  // Override toString untuk debug print yang readable
  @override
  String toString() {
    return 'Task{title: $title, isCompleted: $isCompleted}';
  }
}
// Function utama yang dijalankan pertama kali
void main() {
  // Jalankan aplikasi Flutter, dimulai dari widget MyApp
  runApp(const MyApp());
}

// Deklarasi class MyApp yang extends (turunan dari) StatelessWidget
class MyApp extends StatelessWidget {
  // Constructor dengan key parameter untuk best practices
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App Pemula',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

// Deklarasi class TodoListScreen untuk halaman utama
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

// State class yang menyimpan data dan build UI
class _TodoListScreenState extends State<TodoListScreen> {
List<Task> tasks = [];
  TextEditingController taskController = TextEditingController();
  // Helper function untuk statistic items
Widget _buildStatItem(String label, int count, IconData icon, Color color) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      SizedBox(height: 8),
      Text(
        count.toString(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    ],
  );
}

  // Function untuk menambah task baru ke dalam list
// Function addTask dengan validasi comprehensive dan feedback
void addTask() {
  // Ambil dan bersihkan input text
  String newTaskTitle = taskController.text.trim();

  // Validasi 1: Cek apakah input kosong
  if (newTaskTitle.isEmpty) {
    // Tampilkan SnackBar warning untuk input kosong
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Content dengan icon dan text
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 8),
            Text('Task tidak boleh kosong!'),
          ],
        ),
        // Styling SnackBar
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // Stop execution jika gagal validasi
    return;
  }

  // Validasi 2: Cek task duplikat (case insensitive)
  bool isDuplicate = tasks.any((task) =>
      task.title.toLowerCase() == newTaskTitle.toLowerCase());

  if (isDuplicate) {
    // SnackBar untuk task duplikat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            SizedBox(width: 8),
            // Expanded agar text tidak overflow
            Expanded(child: Text('Task "$newTaskTitle" sudah ada!')),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  // Validasi 3: Cek panjang task maksimal 100 karakter
  if (newTaskTitle.length > 100) {
    // SnackBar untuk task terlalu panjang
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Task terlalu panjang! Maksimal 100 karakter.')),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  // Semua validasi passed - add task
  setState(() {
    Task newTask = Task(title: newTaskTitle);
    tasks.add(newTask);
  });

  // Clear input
  taskController.clear();

  // Success feedback
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 8),
          Expanded(child: Text('Task "$newTaskTitle" berhasil ditambahkan!')),
        ],
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ),
  );

  print('Task ditambahkan: $newTaskTitle');
}
  // Function async untuk menghapus task dengan konfirmasi dialog
void removeTask(int index) async {
  // Simpan nama task yang akan dihapus untuk ditampilkan di dialog
  Task taskToDelete = tasks[index];
    // Tampilkan dialog konfirmasi dan tunggu response user
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      // Builder function untuk membuat content dialog
      builder: (BuildContext context) {
        // AlertDialog = popup konfirmasi
        return AlertDialog(
          // Title dialog dengan icon warning
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Konfirmasi Hapus'),
            ],
          ),
          // Content dialog
          content: Column(
            // Column sekecil mungkin
            mainAxisSize: MainAxisSize.min,
            // Align kiri
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text pertanyaan
              const Text('Apakah kamu yakin ingin menghapus task ini?'),
              const SizedBox(height: 12),
              // Container untuk preview task yang akan dihapus
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                // Preview task dalam tanda kutip
                child: Text(
                  '"${taskToDelete.title}"', // Akses .title property
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          // Actions = tombol-tombol di bawah dialog
          actions: [
            // Tombol Batal
            TextButton(
              // Tutup dialog dan return false
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            // Tombol Hapus
            ElevatedButton(
              // Tutup dialog dan return true
              onPressed: () => Navigator.of(context).pop(true),
              // Styling button merah
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
  );

  // Cek apakah user pilih hapus (shouldDelete == true)
  if (shouldDelete == true) {
    setState(() {
      tasks.removeAt(index); // Hapus dari list
      if (shouldDelete == true) {
  setState(() {
    tasks.removeAt(index);
  });

  // Success feedback for delete
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.delete, color: Colors.white),
          SizedBox(width: 8),
          Expanded(child: Text('Task "${taskToDelete.title}" dihapus')),
        ],
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ),
  );

  print('Task dihapus: ${taskToDelete.title}');
}
    });

    // Debug print
    debugPrint('Task dihapus: $taskToDelete');
    debugPrint('Sisa tasks: ${tasks.length}');
  } else {
    debugPrint('Delete dibatalkan');
  }
}

// Function untuk toggle status completed
void toggleTask(int index) {
  setState(() {
    tasks[index].toggle();
  });

  Task task = tasks[index];
  String message = task.isCompleted
      ? 'Selamat! Task "${task.title}" selesai! 🎉'
      : 'Task "${task.title}" ditandai belum selesai';

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            task.isCompleted ? Icons.celebration : Icons.undo,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: task.isCompleted ? Colors.green : Colors.blue,
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ),
  );

  print('Task ${task.isCompleted ? "completed" : "uncompleted"}: ${task.title}');
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form input task
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: taskController,
                    textCapitalization: TextCapitalization.sentences, // Auto capitalize
                    maxLength: 100, // Limit input length
                    decoration: InputDecoration(
                      hintText: 'Ketik task baru di sini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(Icons.edit),
                      counterText: '', // Hide character counter
                      helperText: 'Maksimal 100 karakter', // Helper text
                    ),
                    onSubmitted: (value) => addTask(), // Enter key also adds task
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: addTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text(
                            'Add Task',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Expanded supaya ListView bisa scroll
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada task',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        Task task = tasks[index]; // Ambil Task object

                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              // Background berubah berdasarkan status
                              color: task.isCompleted ? Colors.green[50] : Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: task.isCompleted
                                  ? Border.all(color: Colors.green[200]!, width: 2) // Border hijau jika selesai
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Opacity(
                              opacity: task.isCompleted ? 0.7 : 1.0, // Completed task lebih transparan
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    // Warna berubah berdasarkan status
                                    color: task.isCompleted ? Colors.green[100] : Colors.blue[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: task.isCompleted
                                        ? Icon(Icons.check, color: Colors.green[700]) // Icon check jika selesai
                                        : Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                  ),
                                ),
                                title: Text(
                                  task.title, // Akses .title dari Task object
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: task.isCompleted ? Colors.grey[600] : Colors.black87,
                                    // STRIKETHROUGH untuk completed task
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Text(
                                  task.isCompleted ? 'Selesai ✅' : 'Belum selesai',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: task.isCompleted ? Colors.green[600] : Colors.grey[600],
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // CHECKBOX untuk toggle complete
                                    IconButton(
                                      icon: Icon(
                                        task.isCompleted
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: task.isCompleted ? Colors.green[600] : Colors.grey[400],
                                      ),
                                      onPressed: () => toggleTask(index),
                                      tooltip: task.isCompleted
                                          ? 'Mark as incomplete'
                                          : 'Mark as complete',
                                    ),
                                    // Delete button
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                                      onPressed: () => removeTask(index),
                                      tooltip: 'Hapus task',
                                    ),
                                  ],
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                // Tap pada item juga bisa toggle
                                onTap: () => toggleTask(index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),

    SizedBox(height: 20),

// Statistics card - hanya tampil jika ada tasks
if (tasks.isNotEmpty)
  Container(
    width: double.infinity,
    padding: EdgeInsets.all(16),
    margin: EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue[50]!, Colors.blue[100]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          'Statistik Progress',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', tasks.length, Icons.list, Colors.blue),
            _buildStatItem(
              'Selesai',
              tasks.where((task) => task.isCompleted).length,
              Icons.check_circle,
              Colors.green
            ),
            _buildStatItem(
              'Belum',
              tasks.where((task) => !task.isCompleted).length,
              Icons.pending,
              Colors.orange
            ),
          ],
        ),
      ],
    ),
  ),  
            // Counter jumlah task
            Text(
              'Total Tasks: ${tasks.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            // Area list dengan conditional rendering
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 104, 61, 61), width: 2),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                // ✅ Conditional rendering
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada task',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambahkan task pertamamu di atas!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        'List akan ditampilkan di sini.\nKamu punya ${tasks.length} tasks.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
