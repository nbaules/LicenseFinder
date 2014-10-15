module LicenseFinder
  # Super-class that adapts data from different package management
  # systems (gems, npm, pip, etc.) to a common interface.
  #
  # For guidance on adding a new system use the shared behavior
  #     it_behaves_like "it conforms to interface required by PackageSaver"
  # and see BundlerPackage, PipPackage and NpmPackage
  class Package
    def self.license_names_from_standard_spec(spec)
      licenses = spec["licenses"] || [spec["license"]].compact
      licenses = [licenses] unless licenses.is_a?(Array)
      licenses.map do |license|
        if license.is_a? Hash
          license["type"]
        else
          license
        end
      end
    end

    def licenses
      @licenses ||= determine_license.to_set
    end

    private

    def determine_license
      if licenses_from_spec.any?
        licenses_from_spec
      elsif licenses_from_files.any?
        licenses_from_files
      else
        [default_license].to_set
      end
    end

    def licenses_from_spec
      license_names_from_spec.map do |name|
        License.find_by_name(name)
      end.to_set
    end

    def licenses_from_files
      license_files.map(&:license).compact.to_set
    end

    def license_files
      PossibleLicenseFiles.find(install_path)
    end

    def default_license
      License.find_by_name nil
    end
  end
end
