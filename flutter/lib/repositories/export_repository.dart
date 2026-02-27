import '../models/person.dart';

class ExportRepository {
  /// Generate CSV content from a list of people.
  String generateCsv(List<Person> people) {
    final buffer = StringBuffer();
    // Header
    buffer.writeln('Name,Date of Birth,Relationship,Connected Through,Known From,Notes,Interests,Gift Ideas');
    // Rows
    for (final person in people) {
      buffer.writeln([
        _escapeCsv(person.name),
        _escapeCsv(person.dateOfBirth),
        _escapeCsv(person.relationship.displayLabel),
        _escapeCsv(person.connectedThrough ?? ''),
        _escapeCsv(person.knownFrom?.displayLabel ?? ''),
        _escapeCsv(person.notes ?? ''),
        _escapeCsv(person.interests?.join('; ') ?? ''),
        _escapeCsv(person.giftIdeas?.join('; ') ?? ''),
      ].join(','));
    }
    return buffer.toString();
  }

  /// Generate a shareable text summary for a single person.
  String generatePersonSummary(Person person) {
    final lines = <String>[];
    lines.add(person.name);
    lines.add('Birthday: ${person.dateOfBirth}');
    lines.add('Relationship: ${person.relationship.displayLabel}');
    if (person.connectedThrough != null && person.connectedThrough!.isNotEmpty) {
      lines.add('Connected through: ${person.connectedThrough}');
    }
    if (person.interests != null && person.interests!.isNotEmpty) {
      lines.add('Interests: ${person.interests!.join(', ')}');
    }
    if (person.giftIdeas != null && person.giftIdeas!.isNotEmpty) {
      lines.add('Gift ideas: ${person.giftIdeas!.join(', ')}');
    }
    return lines.join('\n');
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
