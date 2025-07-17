//
//  MacroWarning.swift
//  ViewConfigurable
//
//  Created by Max Roche on 7/17/25.
//

import SwiftDiagnostics

enum GrindrMacroWarningType: String {
    // ViewConfiguration
    case missingViewConfigurationStruct
    case missingConfigVar
}

struct GrindrMacrosWarning: DiagnosticMessage {
    var message: String
    var diagnosticID: MessageID
    var severity: DiagnosticSeverity

    init(_ type: GrindrMacroWarningType, message: String, severity: DiagnosticSeverity = .warning) {
        self.message = message
        self.diagnosticID = .init(domain: "GrindrMacros", id: type.rawValue)
        self.severity = severity
    }

    init(_ type: GrindrMacroWarningType, error: MacroError, severity: DiagnosticSeverity) {
        self.message = error.localizedDescription
        self.diagnosticID = .init(domain: "GrindrMacros", id: type.rawValue)
        self.severity = severity
    }
}
