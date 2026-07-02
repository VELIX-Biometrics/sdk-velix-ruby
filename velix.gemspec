Gem::Specification.new do |spec|
  spec.name          = "velix-sdk"
  spec.version       = "0.1.0.pre.alpha1"
  spec.authors       = ["Velix Biometrics"]
  spec.email         = ["dev@velixbiometrics.com"]
  spec.summary       = "SDK oficial do VELIX para Ruby"
  spec.description   = "Integre controle de acesso biométrico VELIX em aplicações Ruby."
  spec.homepage      = "https://velixbiometrics.com"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.files         = Dir["lib/**/*.rb", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = "https://github.com/velix/velix-sdk-ruby"
  spec.metadata["changelog_uri"]     = "https://github.com/velix/velix-sdk-ruby/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Zero runtime dependencies — usa stdlib net/http
end
