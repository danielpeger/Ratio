//
//  WelcomeView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 09. 02.
//

import SwiftUI
import UIKit

struct TicksCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.49348*width, y: 0.65987*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.66*height), control1: CGPoint(x: 0.49562*width, y: 0.65996*height), control2: CGPoint(x: 0.4978*width, y: 0.66*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: height))
        path.addCurve(to: CGPoint(x: 0.48034*width, y: 0.99961*height), control1: CGPoint(x: 0.49342*width, y: height), control2: CGPoint(x: 0.48686*width, y: 0.99987*height))
        path.addLine(to: CGPoint(x: 0.49348*width, y: 0.65987*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.51965*width, y: 0.99961*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: height), control1: CGPoint(x: 0.51313*width, y: 0.99987*height), control2: CGPoint(x: 0.50658*width, y: height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.66*height))
        path.addCurve(to: CGPoint(x: 0.50652*width, y: 0.65987*height), control1: CGPoint(x: 0.5022*width, y: 0.66*height), control2: CGPoint(x: 0.50438*width, y: 0.65996*height))
        path.addLine(to: CGPoint(x: 0.51965*width, y: 0.99961*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.46234*width, y: 0.65562*height))
        path.addCurve(to: CGPoint(x: 0.47454*width, y: 0.65804*height), control1: CGPoint(x: 0.46633*width, y: 0.65658*height), control2: CGPoint(x: 0.4704*width, y: 0.65739*height))
        path.addLine(to: CGPoint(x: 0.42176*width, y: 0.9939*height))
        path.addCurve(to: CGPoint(x: 0.38323*width, y: 0.98628*height), control1: CGPoint(x: 0.40874*width, y: 0.99186*height), control2: CGPoint(x: 0.39589*width, y: 0.98931*height))
        path.addLine(to: CGPoint(x: 0.46234*width, y: 0.65562*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.61677*width, y: 0.98628*height))
        path.addCurve(to: CGPoint(x: 0.57824*width, y: 0.9939*height), control1: CGPoint(x: 0.6041*width, y: 0.98931*height), control2: CGPoint(x: 0.59125*width, y: 0.99186*height))
        path.addLine(to: CGPoint(x: 0.52546*width, y: 0.65804*height))
        path.addCurve(to: CGPoint(x: 0.53766*width, y: 0.65562*height), control1: CGPoint(x: 0.5296*width, y: 0.65739*height), control2: CGPoint(x: 0.53367*width, y: 0.65658*height))
        path.addLine(to: CGPoint(x: 0.61677*width, y: 0.98628*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.43316*width, y: 0.6455*height))
        path.addCurve(to: CGPoint(x: 0.44461*width, y: 0.65025*height), control1: CGPoint(x: 0.43691*width, y: 0.64723*height), control2: CGPoint(x: 0.44073*width, y: 0.64882*height))
        path.addLine(to: CGPoint(x: 0.38575*width, y: 0.80973*height))
        path.addLine(to: CGPoint(x: 0.38575*width, y: 0.80974*height))
        path.addLine(to: CGPoint(x: 0.32689*width, y: 0.96921*height))
        path.addCurve(to: CGPoint(x: 0.29062*width, y: 0.95417*height), control1: CGPoint(x: 0.31456*width, y: 0.96466*height), control2: CGPoint(x: 0.30247*width, y: 0.95964*height))
        path.addLine(to: CGPoint(x: 0.43316*width, y: 0.6455*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.70937*width, y: 0.95417*height))
        path.addCurve(to: CGPoint(x: 0.6731*width, y: 0.96921*height), control1: CGPoint(x: 0.69752*width, y: 0.95964*height), control2: CGPoint(x: 0.68543*width, y: 0.96466*height))
        path.addLine(to: CGPoint(x: 0.61425*width, y: 0.80974*height))
        path.addLine(to: CGPoint(x: 0.55539*width, y: 0.65025*height))
        path.addCurve(to: CGPoint(x: 0.56684*width, y: 0.6455*height), control1: CGPoint(x: 0.55927*width, y: 0.64882*height), control2: CGPoint(x: 0.56309*width, y: 0.64723*height))
        path.addLine(to: CGPoint(x: 0.70937*width, y: 0.95417*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.40616*width, y: 0.62964*height))
        path.addCurve(to: CGPoint(x: 0.41664*width, y: 0.63665*height), control1: CGPoint(x: 0.40956*width, y: 0.63212*height), control2: CGPoint(x: 0.41306*width, y: 0.63446*height))
        path.addLine(to: CGPoint(x: 0.23872*width, y: 0.92637*height))
        path.addCurve(to: CGPoint(x: 0.20609*width, y: 0.90454*height), control1: CGPoint(x: 0.22755*width, y: 0.91951*height), control2: CGPoint(x: 0.21666*width, y: 0.91222*height))
        path.addLine(to: CGPoint(x: 0.40616*width, y: 0.62964*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.7939*width, y: 0.90454*height))
        path.addCurve(to: CGPoint(x: 0.76128*width, y: 0.92637*height), control1: CGPoint(x: 0.78333*width, y: 0.91222*height), control2: CGPoint(x: 0.77245*width, y: 0.91951*height))
        path.addLine(to: CGPoint(x: 0.58336*width, y: 0.63665*height))
        path.addCurve(to: CGPoint(x: 0.59384*width, y: 0.62964*height), control1: CGPoint(x: 0.58694*width, y: 0.63446*height), control2: CGPoint(x: 0.59044*width, y: 0.63212*height))
        path.addLine(to: CGPoint(x: 0.7939*width, y: 0.90454*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.38245*width, y: 0.60855*height))
        path.addCurve(to: CGPoint(x: 0.39145*width, y: 0.61755*height), control1: CGPoint(x: 0.38533*width, y: 0.61167*height), control2: CGPoint(x: 0.38833*width, y: 0.61467*height))
        path.addLine(to: CGPoint(x: 0.27602*width, y: 0.74235*height))
        path.addLine(to: CGPoint(x: 0.27603*width, y: 0.74236*height))
        path.addLine(to: CGPoint(x: 0.1606*width, y: 0.86716*height))
        path.addCurve(to: CGPoint(x: 0.13284*width, y: 0.83939*height), control1: CGPoint(x: 0.15099*width, y: 0.85827*height), control2: CGPoint(x: 0.14173*width, y: 0.84901*height))
        path.addLine(to: CGPoint(x: 0.38245*width, y: 0.60855*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.61755*width, y: 0.60855*height))
        path.addLine(to: CGPoint(x: 0.86716*width, y: 0.83939*height))
        path.addCurve(to: CGPoint(x: 0.83939*width, y: 0.86716*height), control1: CGPoint(x: 0.85827*width, y: 0.84901*height), control2: CGPoint(x: 0.84901*width, y: 0.85827*height))
        path.addLine(to: CGPoint(x: 0.72398*width, y: 0.74236*height))
        path.addLine(to: CGPoint(x: 0.60855*width, y: 0.61755*height))
        path.addCurve(to: CGPoint(x: 0.61755*width, y: 0.60855*height), control1: CGPoint(x: 0.61167*width, y: 0.61467*height), control2: CGPoint(x: 0.61467*width, y: 0.61167*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.36335*width, y: 0.58336*height))
        path.addCurve(to: CGPoint(x: 0.37036*width, y: 0.59384*height), control1: CGPoint(x: 0.36554*width, y: 0.58694*height), control2: CGPoint(x: 0.36788*width, y: 0.59044*height))
        path.addLine(to: CGPoint(x: 0.09546*width, y: 0.7939*height))
        path.addCurve(to: CGPoint(x: 0.07362*width, y: 0.76128*height), control1: CGPoint(x: 0.08777*width, y: 0.78333*height), control2: CGPoint(x: 0.08048*width, y: 0.77244*height))
        path.addLine(to: CGPoint(x: 0.36335*width, y: 0.58336*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.92637*width, y: 0.76128*height))
        path.addCurve(to: CGPoint(x: 0.90454*width, y: 0.7939*height), control1: CGPoint(x: 0.91951*width, y: 0.77245*height), control2: CGPoint(x: 0.91222*width, y: 0.78333*height))
        path.addLine(to: CGPoint(x: 0.62964*width, y: 0.59384*height))
        path.addCurve(to: CGPoint(x: 0.63665*width, y: 0.58336*height), control1: CGPoint(x: 0.63212*width, y: 0.59044*height), control2: CGPoint(x: 0.63446*width, y: 0.58694*height))
        path.addLine(to: CGPoint(x: 0.92637*width, y: 0.76128*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.34975*width, y: 0.55539*height))
        path.addCurve(to: CGPoint(x: 0.3545*width, y: 0.56684*height), control1: CGPoint(x: 0.35118*width, y: 0.55927*height), control2: CGPoint(x: 0.35277*width, y: 0.56309*height))
        path.addLine(to: CGPoint(x: 0.04583*width, y: 0.70937*height))
        path.addCurve(to: CGPoint(x: 0.03078*width, y: 0.6731*height), control1: CGPoint(x: 0.04035*width, y: 0.69752*height), control2: CGPoint(x: 0.03533*width, y: 0.68543*height))
        path.addLine(to: CGPoint(x: 0.34975*width, y: 0.55539*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.80973*width, y: 0.61425*height))
        path.addLine(to: CGPoint(x: 0.96921*width, y: 0.6731*height))
        path.addCurve(to: CGPoint(x: 0.95417*width, y: 0.70937*height), control1: CGPoint(x: 0.96466*width, y: 0.68543*height), control2: CGPoint(x: 0.95964*width, y: 0.69752*height))
        path.addLine(to: CGPoint(x: 0.6455*width, y: 0.56684*height))
        path.addCurve(to: CGPoint(x: 0.65025*width, y: 0.55539*height), control1: CGPoint(x: 0.64723*width, y: 0.56309*height), control2: CGPoint(x: 0.64882*width, y: 0.55927*height))
        path.addLine(to: CGPoint(x: 0.80973*width, y: 0.61425*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.34196*width, y: 0.52546*height))
        path.addCurve(to: CGPoint(x: 0.34438*width, y: 0.53766*height), control1: CGPoint(x: 0.34261*width, y: 0.5296*height), control2: CGPoint(x: 0.34342*width, y: 0.53367*height))
        path.addLine(to: CGPoint(x: 0.01371*width, y: 0.61677*height))
        path.addCurve(to: CGPoint(x: 0.00609*width, y: 0.57824*height), control1: CGPoint(x: 0.01068*width, y: 0.6041*height), control2: CGPoint(x: 0.00814*width, y: 0.59125*height))
        path.addLine(to: CGPoint(x: 0.34196*width, y: 0.52546*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.9939*width, y: 0.57824*height))
        path.addCurve(to: CGPoint(x: 0.98628*width, y: 0.61677*height), control1: CGPoint(x: 0.99186*width, y: 0.59125*height), control2: CGPoint(x: 0.98931*width, y: 0.6041*height))
        path.addLine(to: CGPoint(x: 0.65562*width, y: 0.53766*height))
        path.addCurve(to: CGPoint(x: 0.65804*width, y: 0.52546*height), control1: CGPoint(x: 0.65658*width, y: 0.53367*height), control2: CGPoint(x: 0.65739*width, y: 0.5296*height))
        path.addLine(to: CGPoint(x: 0.9939*width, y: 0.57824*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0, y: 0.5*height))
        path.addCurve(to: CGPoint(x: 0.00038*width, y: 0.48034*height), control1: CGPoint(x: 0, y: 0.49342*height), control2: CGPoint(x: 0.00013*width, y: 0.48686*height))
        path.addLine(to: CGPoint(x: 0.34012*width, y: 0.49348*height))
        path.addCurve(to: CGPoint(x: 0.34*width, y: 0.5*height), control1: CGPoint(x: 0.34004*width, y: 0.49562*height), control2: CGPoint(x: 0.34*width, y: 0.4978*height))
        path.addCurve(to: CGPoint(x: 0.34012*width, y: 0.50652*height), control1: CGPoint(x: 0.34*width, y: 0.5022*height), control2: CGPoint(x: 0.34004*width, y: 0.50438*height))
        path.addLine(to: CGPoint(x: 0.00038*width, y: 0.51965*height))
        path.addCurve(to: CGPoint(x: 0, y: 0.5*height), control1: CGPoint(x: 0.00013*width, y: 0.51313*height), control2: CGPoint(x: 0, y: 0.50658*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.99961*width, y: 0.48034*height))
        path.addCurve(to: CGPoint(x: width, y: 0.5*height), control1: CGPoint(x: 0.99987*width, y: 0.48686*height), control2: CGPoint(x: width, y: 0.49342*height))
        path.addCurve(to: CGPoint(x: 0.99961*width, y: 0.51965*height), control1: CGPoint(x: width, y: 0.50658*height), control2: CGPoint(x: 0.99987*width, y: 0.51313*height))
        path.addLine(to: CGPoint(x: 0.65987*width, y: 0.50652*height))
        path.addCurve(to: CGPoint(x: 0.66*width, y: 0.5*height), control1: CGPoint(x: 0.65996*width, y: 0.50438*height), control2: CGPoint(x: 0.66*width, y: 0.5022*height))
        path.addCurve(to: CGPoint(x: 0.65987*width, y: 0.49348*height), control1: CGPoint(x: 0.66*width, y: 0.4978*height), control2: CGPoint(x: 0.65996*width, y: 0.49562*height))
        path.addLine(to: CGPoint(x: 0.99961*width, y: 0.48034*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.34438*width, y: 0.46234*height))
        path.addCurve(to: CGPoint(x: 0.34196*width, y: 0.47454*height), control1: CGPoint(x: 0.34342*width, y: 0.46633*height), control2: CGPoint(x: 0.34261*width, y: 0.4704*height))
        path.addLine(to: CGPoint(x: 0.00609*width, y: 0.42176*height))
        path.addCurve(to: CGPoint(x: 0.01371*width, y: 0.38323*height), control1: CGPoint(x: 0.00814*width, y: 0.40874*height), control2: CGPoint(x: 0.01068*width, y: 0.39589*height))
        path.addLine(to: CGPoint(x: 0.34438*width, y: 0.46234*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.98628*width, y: 0.38323*height))
        path.addCurve(to: CGPoint(x: 0.9939*width, y: 0.42176*height), control1: CGPoint(x: 0.98931*width, y: 0.39589*height), control2: CGPoint(x: 0.99186*width, y: 0.40874*height))
        path.addLine(to: CGPoint(x: 0.65804*width, y: 0.47454*height))
        path.addCurve(to: CGPoint(x: 0.65562*width, y: 0.46234*height), control1: CGPoint(x: 0.65739*width, y: 0.4704*height), control2: CGPoint(x: 0.65658*width, y: 0.46633*height))
        path.addLine(to: CGPoint(x: 0.98628*width, y: 0.38323*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.3545*width, y: 0.43316*height))
        path.addCurve(to: CGPoint(x: 0.34975*width, y: 0.44461*height), control1: CGPoint(x: 0.35277*width, y: 0.43691*height), control2: CGPoint(x: 0.35118*width, y: 0.44073*height))
        path.addLine(to: CGPoint(x: 0.19026*width, y: 0.38575*height))
        path.addLine(to: CGPoint(x: 0.03078*width, y: 0.32689*height))
        path.addCurve(to: CGPoint(x: 0.04583*width, y: 0.29062*height), control1: CGPoint(x: 0.03533*width, y: 0.31456*height), control2: CGPoint(x: 0.04035*width, y: 0.30247*height))
        path.addLine(to: CGPoint(x: 0.3545*width, y: 0.43316*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.95417*width, y: 0.29062*height))
        path.addCurve(to: CGPoint(x: 0.96921*width, y: 0.32689*height), control1: CGPoint(x: 0.95964*width, y: 0.30247*height), control2: CGPoint(x: 0.96466*width, y: 0.31456*height))
        path.addLine(to: CGPoint(x: 0.80974*width, y: 0.38575*height))
        path.addLine(to: CGPoint(x: 0.80973*width, y: 0.38575*height))
        path.addLine(to: CGPoint(x: 0.65025*width, y: 0.44461*height))
        path.addCurve(to: CGPoint(x: 0.6455*width, y: 0.43316*height), control1: CGPoint(x: 0.64882*width, y: 0.44073*height), control2: CGPoint(x: 0.64723*width, y: 0.43691*height))
        path.addLine(to: CGPoint(x: 0.95417*width, y: 0.29062*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.37036*width, y: 0.40616*height))
        path.addCurve(to: CGPoint(x: 0.36335*width, y: 0.41664*height), control1: CGPoint(x: 0.36788*width, y: 0.40956*height), control2: CGPoint(x: 0.36554*width, y: 0.41306*height))
        path.addLine(to: CGPoint(x: 0.07362*width, y: 0.23872*height))
        path.addCurve(to: CGPoint(x: 0.09546*width, y: 0.20609*height), control1: CGPoint(x: 0.08048*width, y: 0.22755*height), control2: CGPoint(x: 0.08777*width, y: 0.21666*height))
        path.addLine(to: CGPoint(x: 0.37036*width, y: 0.40616*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.90454*width, y: 0.20609*height))
        path.addCurve(to: CGPoint(x: 0.92637*width, y: 0.23872*height), control1: CGPoint(x: 0.91222*width, y: 0.21666*height), control2: CGPoint(x: 0.91951*width, y: 0.22755*height))
        path.addLine(to: CGPoint(x: 0.63665*width, y: 0.41664*height))
        path.addCurve(to: CGPoint(x: 0.62964*width, y: 0.40616*height), control1: CGPoint(x: 0.63446*width, y: 0.41306*height), control2: CGPoint(x: 0.63212*width, y: 0.40956*height))
        path.addLine(to: CGPoint(x: 0.90454*width, y: 0.20609*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.39145*width, y: 0.38245*height))
        path.addCurve(to: CGPoint(x: 0.38245*width, y: 0.39145*height), control1: CGPoint(x: 0.38833*width, y: 0.38533*height), control2: CGPoint(x: 0.38533*width, y: 0.38833*height))
        path.addLine(to: CGPoint(x: 0.25764*width, y: 0.27602*height))
        path.addLine(to: CGPoint(x: 0.13284*width, y: 0.1606*height))
        path.addCurve(to: CGPoint(x: 0.1606*width, y: 0.13284*height), control1: CGPoint(x: 0.14173*width, y: 0.15099*height), control2: CGPoint(x: 0.15099*width, y: 0.14173*height))
        path.addLine(to: CGPoint(x: 0.39145*width, y: 0.38245*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.83939*width, y: 0.13284*height))
        path.addCurve(to: CGPoint(x: 0.86716*width, y: 0.1606*height), control1: CGPoint(x: 0.84901*width, y: 0.14173*height), control2: CGPoint(x: 0.85827*width, y: 0.15099*height))
        path.addLine(to: CGPoint(x: 0.74236*width, y: 0.27603*height))
        path.addLine(to: CGPoint(x: 0.74235*width, y: 0.27602*height))
        path.addLine(to: CGPoint(x: 0.61755*width, y: 0.39145*height))
        path.addCurve(to: CGPoint(x: 0.60855*width, y: 0.38245*height), control1: CGPoint(x: 0.61467*width, y: 0.38833*height), control2: CGPoint(x: 0.61167*width, y: 0.38533*height))
        path.addLine(to: CGPoint(x: 0.83939*width, y: 0.13284*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.41664*width, y: 0.36335*height))
        path.addCurve(to: CGPoint(x: 0.40616*width, y: 0.37036*height), control1: CGPoint(x: 0.41306*width, y: 0.36554*height), control2: CGPoint(x: 0.40956*width, y: 0.36788*height))
        path.addLine(to: CGPoint(x: 0.20609*width, y: 0.09546*height))
        path.addCurve(to: CGPoint(x: 0.23872*width, y: 0.07362*height), control1: CGPoint(x: 0.21666*width, y: 0.08777*height), control2: CGPoint(x: 0.22755*width, y: 0.08048*height))
        path.addLine(to: CGPoint(x: 0.41664*width, y: 0.36335*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.76128*width, y: 0.07362*height))
        path.addCurve(to: CGPoint(x: 0.7939*width, y: 0.09546*height), control1: CGPoint(x: 0.77244*width, y: 0.08048*height), control2: CGPoint(x: 0.78333*width, y: 0.08777*height))
        path.addLine(to: CGPoint(x: 0.59384*width, y: 0.37036*height))
        path.addCurve(to: CGPoint(x: 0.58336*width, y: 0.36335*height), control1: CGPoint(x: 0.59044*width, y: 0.36788*height), control2: CGPoint(x: 0.58694*width, y: 0.36554*height))
        path.addLine(to: CGPoint(x: 0.76128*width, y: 0.07362*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.38575*width, y: 0.19026*height))
        path.addLine(to: CGPoint(x: 0.44461*width, y: 0.34975*height))
        path.addCurve(to: CGPoint(x: 0.43316*width, y: 0.3545*height), control1: CGPoint(x: 0.44073*width, y: 0.35118*height), control2: CGPoint(x: 0.43691*width, y: 0.35277*height))
        path.addLine(to: CGPoint(x: 0.29062*width, y: 0.04583*height))
        path.addCurve(to: CGPoint(x: 0.32689*width, y: 0.03078*height), control1: CGPoint(x: 0.30247*width, y: 0.04035*height), control2: CGPoint(x: 0.31456*width, y: 0.03533*height))
        path.addLine(to: CGPoint(x: 0.38575*width, y: 0.19026*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.6731*width, y: 0.03078*height))
        path.addCurve(to: CGPoint(x: 0.70937*width, y: 0.04583*height), control1: CGPoint(x: 0.68543*width, y: 0.03533*height), control2: CGPoint(x: 0.69752*width, y: 0.04035*height))
        path.addLine(to: CGPoint(x: 0.56684*width, y: 0.3545*height))
        path.addCurve(to: CGPoint(x: 0.55539*width, y: 0.34975*height), control1: CGPoint(x: 0.56309*width, y: 0.35277*height), control2: CGPoint(x: 0.55927*width, y: 0.35118*height))
        path.addLine(to: CGPoint(x: 0.6731*width, y: 0.03078*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.47454*width, y: 0.34196*height))
        path.addCurve(to: CGPoint(x: 0.46234*width, y: 0.34438*height), control1: CGPoint(x: 0.4704*width, y: 0.34261*height), control2: CGPoint(x: 0.46633*width, y: 0.34342*height))
        path.addLine(to: CGPoint(x: 0.38323*width, y: 0.01371*height))
        path.addCurve(to: CGPoint(x: 0.42176*width, y: 0.00609*height), control1: CGPoint(x: 0.39589*width, y: 0.01068*height), control2: CGPoint(x: 0.40874*width, y: 0.00814*height))
        path.addLine(to: CGPoint(x: 0.47454*width, y: 0.34196*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.57824*width, y: 0.00609*height))
        path.addCurve(to: CGPoint(x: 0.61677*width, y: 0.01371*height), control1: CGPoint(x: 0.59125*width, y: 0.00814*height), control2: CGPoint(x: 0.6041*width, y: 0.01068*height))
        path.addLine(to: CGPoint(x: 0.53766*width, y: 0.34438*height))
        path.addCurve(to: CGPoint(x: 0.52546*width, y: 0.34196*height), control1: CGPoint(x: 0.53367*width, y: 0.34342*height), control2: CGPoint(x: 0.5296*width, y: 0.34261*height))
        path.addLine(to: CGPoint(x: 0.57824*width, y: 0.00609*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.5*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.51965*width, y: 0.00038*height), control1: CGPoint(x: 0.50658*width, y: 0), control2: CGPoint(x: 0.51313*width, y: 0.00013*height))
        path.addLine(to: CGPoint(x: 0.50652*width, y: 0.34012*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.34*height), control1: CGPoint(x: 0.50438*width, y: 0.34004*height), control2: CGPoint(x: 0.5022*width, y: 0.34*height))
        path.addCurve(to: CGPoint(x: 0.49348*width, y: 0.34012*height), control1: CGPoint(x: 0.4978*width, y: 0.34*height), control2: CGPoint(x: 0.49562*width, y: 0.34004*height))
        path.addLine(to: CGPoint(x: 0.48034*width, y: 0.00038*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0), control1: CGPoint(x: 0.48686*width, y: 0.00013*height), control2: CGPoint(x: 0.49342*width, y: 0))
        path.closeSubpath()
        return path
    }
}

struct WelcomeView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var startDate = Date()
    @State private var trim: Double = 0.0
    @State private var appear: Double = 0.0
    private let fastPhase: TimeInterval = 1
    private let fastPeriod: TimeInterval = 6   // seconds per rotation during fast phase
    private let slowPeriod: TimeInterval = 60  // seconds per rotation after
    private let rampPhase: TimeInterval = 4     // seconds to interpolate from fast to slow
    @State private var lastHapticDate: Date = Date()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    // Haptic behavior
    private let hapticMaxHz: Double = 40      // peak rate when spring speed is max
    private let hapticBaselineHz: Double = 0.53  // fallback rate after spring settles
    // Match trim's spring animation parameters
    private let trimSpringResponse: Double = 3
    private let trimSpringDamping: Double = 0.28
    
    private var mainColor: Color { colorScheme == .dark ? .accent : Color(.systemBackground) }

    private func angleDegrees(for date: Date) -> Double {
        let t = max(0, date.timeIntervalSince(startDate))
        let rFast = 1.0 / fastPeriod
        let rSlow = 1.0 / slowPeriod

        if t <= fastPhase {
            let revs = t * rFast
            return -360 * revs
        } else if t <= fastPhase + rampPhase {
            let u = t - fastPhase
            let b = (rSlow - rFast) / rampPhase
            let revs = fastPhase * rFast + rFast * u + 0.5 * b * u * u
            return -360 * revs
        } else {
            let rampIntegral = rFast * rampPhase + 0.5 * ((rSlow - rFast) / rampPhase) * rampPhase * rampPhase
            let revs = fastPhase * rFast + rampIntegral + (t - fastPhase - rampPhase) * rSlow
            return -360 * revs
        }
    }

    private func hapticFrequency(at t: TimeInterval) -> Double {
        // During spring window, drive haptic frequency from the instantaneous spring velocity magnitude
        let springWindow: TimeInterval = fastPhase + rampPhase + 2.0
        if t <= springWindow {
            let s = springNormalizedSpeed(at: t)
            return max(0.0, hapticMaxHz * s)
        }
        // After spring settles, use baseline frequency indefinitely
        return hapticBaselineHz
    }

    private func maybeFireHaptic(at date: Date) {
        let t = max(0, date.timeIntervalSince(startDate))
        let freq = max(0.1, hapticFrequency(at: t))
        let interval = 1.0 / freq
        if date.timeIntervalSince(lastHapticDate) >= interval {
            selectionGenerator.selectionChanged()
            selectionGenerator.prepare()
            lastHapticDate = date
        }
    }

    private func springNormalizedSpeed(at t: TimeInterval) -> Double {
        // Underdamped second-order step response derivative magnitude, normalized by a sampled peak
        let zeta = max(0.0, min(0.999, trimSpringDamping))
        let omega0 = 2.0 * .pi / max(0.001, trimSpringResponse)
        let omegaD = omega0 * sqrt(max(0.0, 1.0 - zeta * zeta))
        let phi = atan2(sqrt(max(0.0, 1.0 - zeta * zeta)), zeta)
        let A = 1.0 / max(1e-6, sqrt(max(0.0, 1.0 - zeta * zeta)))

        func v(_ time: Double) -> Double {
            let expTerm = exp(-zeta * omega0 * time)
            let arg = omegaD * time + phi
            // Velocity of step response: derivative of x(t)
            let val = A * expTerm * (zeta * omega0 * sin(arg) - omegaD * cos(arg))
            return val
        }

        // Sample over a reasonable window to estimate peak speed
        let sampleWindow = max(2.0 * trimSpringResponse, fastPhase + rampPhase + 2.0)
        let samples = 240
        var vmax: Double = 0
        if samples > 0 {
            let dt = sampleWindow / Double(samples)
            var i = 0
            while i <= samples {
                let vv = abs(v(Double(i) * dt))
                if vv > vmax { vmax = vv }
                i += 1
            }
        }
        if vmax <= 0 { return 0 }
        return min(1.0, abs(v(t)) / vmax)
    }

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .stroke(Color("RedGradientTopColor"), lineWidth: 54.666)
                        .frame(width: 105.6666, height: 105.6666)
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 10)
                    TimelineView(.animation) { context in
                        TicksCircle()
                            .scaledToFit()
                            .rotationEffect(.degrees(angleDegrees(for: context.date)))
                            .frame(width: 160, height: 160)
                            .onChange(of: context.date) { _, newDate in
                                maybeFireHaptic(at: newDate)
                            }
                    }
                    Circle()
                        .trim(from: 0, to: trim)
                        .rotation(Angle(degrees: 270))
                        .scale(x: -1, y: 1)
                        .stroke(mainColor, lineWidth: 54.666)
                        .frame(width: 105.6666, height: 105.6666)
                        .animation(.spring(
                            response: trimSpringResponse,
                            dampingFraction: trimSpringDamping,
                        ), value: trim)
                    // Angular gradient overlay masked to ring thickness
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color("RedGradientTopColor"), location: 0.0),
                            .init(color: Color("RedGradientTopColor").opacity(0), location: trim),
                            .init(color: Color("RedGradientTopColor"), location: 1.0)
                        ]),
                        center: .center,
                        startAngle: .degrees(0),   // top
                        endAngle: .degrees(360)     // full 360 sweep from top
                    )
                        .frame(width: 105.6666, height: 105.6666)
                        .mask(
                            Circle()
                                .stroke(lineWidth: 54.666)
                                .frame(width: 105.6666, height: 105.6666)
                        )
                        .rotationEffect(Angle(degrees: -90))
                        .scaleEffect(x: -1, y: 1)
                        .animation(.spring(
                            response: trimSpringResponse,
                            dampingFraction: trimSpringDamping,
                        ), value: trim)
                    
                    Circle()
                        .stroke(lineWidth: 54.666)
                        .frame(width: 105.6666, height: 105.6666)
                        .foregroundStyle(
                            .white.opacity(0.04)
                            .shadow(.inner(color: .white.opacity(1), radius: 8, x: 0, y: 0))
                        )
                }
                Text("Welcome to Ratio")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .opacity(appear)
                    .offset(y: (1 - appear) * 16)
                    .blur(radius: (1 - appear) * 5)
                    .animation(.easeOut(duration: 0.5).delay(4), value: appear)
                
                VStack(alignment:.leading, spacing: 32) {
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(mainColor.opacity(0.8))
                            .font(.system(size: 40))
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Get the best out of your coffee")
                                .fontWeight(.semibold)
                            Text("Achieve café-quality espresso at home.")
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                                .opacity(0.75)
                        }
                    }
                    .opacity(appear)
                    .offset(y: (1 - appear) * 16)
                    .blur(radius: (1 - appear) * 5)
                    .animation(.easeOut(duration: 0.5).delay(4.25), value: appear)
                    
                    HStack(alignment: .top, spacing: 16) {
                        Image("cup.sparkle")
                            .foregroundStyle(mainColor.opacity(0.8))
                            .font(.system(size: 36))
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Train your taste buds")
                                .fontWeight(.semibold)
                            Text("Taste and reflect to sharpen your palate.")
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                                .opacity(0.75)
                        }
                    }
                    .opacity(appear)
                    .offset(y: (1 - appear) * 16)
                    .blur(radius: (1 - appear) * 5)
                    .animation(.easeOut(duration: 0.5).delay(4.5), value: appear)
                    
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "dial.low.fill")
                            .foregroundStyle(mainColor.opacity(0.8))
                            .font(.system(size: 40))
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dial in, one morning at a time")
                                .fontWeight(.semibold)
                            Text("Leave notes after each brew to guide your next one.")
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                                .opacity(0.75)
                        }
                    }
                    .opacity(appear)
                    .offset(y: (1 - appear) * 16)
                    .blur(radius: (1 - appear) * 5)
                    .animation(.easeOut(duration: 0.5).delay(4.75), value: appear)
                    
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(mainColor.opacity(0.8))
                            .font(.system(size: 37))
                            .frame(width: 40, height: 48)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Always remember settings")
                                .fontWeight(.semibold)
                            Text("Nail the perfect shot? Pin it, so you can easily recreate it later.")
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                                .opacity(0.75)
                        }
                    }
                    .opacity(appear)
                    .offset(y: (1 - appear) * 16)
                    .blur(radius: (1 - appear) * 5)
                    .animation(.easeOut(duration: 0.5).delay(5), value: appear)
                }
            }
            Spacer()
            Button(action: {
                
            }) {
                Text("Continue")
                    .fontWeight(.medium)
                    .foregroundStyle(.accent)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(14)
                    .background(Color(.systemBackground))
                    .contentShape(Capsule())
            }
            .clipShape(Capsule())
            .buttonStyle(.plain)
            .opacity(appear)
            .offset(y: (1 - appear) * 16)
            .blur(radius: (1 - appear) * 5)
            .animation(.easeOut(duration: 0.5).delay(5.25), value: appear)
        }
        .foregroundStyle(mainColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 32)
        .padding(.top, 48)
        .padding(.bottom, 32)
        .background(colorScheme == .light ? Color.red.gradient : Color.clear.gradient)
        .background(colorScheme == .dark ? Color(.systemBackground) : Color.clear)
        .onAppear {
            startDate = Date()
            trim = 0.66
            appear = 1.0
            lastHapticDate = startDate
            selectionGenerator.prepare()
        }
    }
}

#Preview {
    WelcomeView()
}
