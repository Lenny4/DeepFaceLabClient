class Device {
  Device(this.index, this.tfDevType, this.name, this.totalMem, this.totalMemGb,
      this.freeMem, this.freeMemGb);

  int index;
  String tfDevType;
  String name;
  double totalMem;
  double totalMemGb;
  double freeMem;
  double freeMemGb;

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        json['index'] as int,
        json['tf_dev_type'] as String,
        json['name'] as String,
        (json['total_mem'] as num).toDouble(),
        (json['total_mem_gb'] as num).toDouble(),
        (json['free_mem'] as num).toDouble(),
        (json['free_mem_gb'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'index': index,
        'tf_dev_type': tfDevType,
        'name': name,
        'total_mem': totalMem,
        'total_mem_gb': totalMemGb,
        'free_mem': freeMem,
        'free_mem_gb': freeMemGb,
      };
}
