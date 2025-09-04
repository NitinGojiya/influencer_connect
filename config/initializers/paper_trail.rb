# Use YAML serializer
PaperTrail.config.serializer = :yaml

# Allow classes that YAML might otherwise block
YAML.safe_load("---", permitted_classes: [Symbol, Date, Time, BigDecimal, ActiveSupport::TimeWithZone])
